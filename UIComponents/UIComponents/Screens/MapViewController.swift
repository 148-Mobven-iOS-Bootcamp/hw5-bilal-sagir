//
//  MapViewController.swift
//  UIComponents
//
//  Created by Semih Emre ÜNLÜ on 9.01.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    var myRoutes = [MKPolyline]()
    var myRenders = [MKPolylineRenderer]()
    var activeNumber = 0
    
    private var currentCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationPermission()
        addLongGestureRecognizer()
    }

    @IBAction func showCurrentLocationTapped(_ sender: UIButton) {
        locationManager.requestLocation()
    }

    @IBAction func drawRouteButtonTapped(_ sender: UIButton) {
        guard let currentCoordinate = currentCoordinate,
              let destinationCoordinate = destinationCoordinate else {
                  // log
                  // alert
            return
        }

        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let source = MKMapItem(placemark: sourcePlacemark)

        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destination = MKMapItem(placemark: destinationPlacemark)

        let directionRequest = MKDirections.Request()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true

        let direction = MKDirections(request: directionRequest)

        direction.calculate { response, error in
            guard error == nil else {
                //log error
                //show error
                print(error?.localizedDescription)
                return
            }

            guard let polyline: MKPolyline = response?.routes.first?.polyline else { return }

            let rect = polyline.boundingMapRect
            let region = MKCoordinateRegion(rect)
            self.mapView.setRegion(region, animated: true)
            
            for route in response?.routes ?? [] { // routes polylines appending to an array
                self.myRoutes.append(route.polyline)
            }
            
            self.mapView.addOverlays(self.myRoutes, level: .aboveLabels) // adding all overlays at once
        }
    }


    // MARK: - HOMEWORK BUTTONS
    @IBAction func backRoute(_ sender: UIBarButtonItem) {
        
        let index = myRenders.count
    
        if activeNumber == 0 {
            myRenders[activeNumber].strokeColor = .systemBlue
            activeNumber = index - 1
            myRenders[activeNumber].strokeColor = .blue
            let rect = self.myRoutes[activeNumber].boundingMapRect
            let region = MKCoordinateRegion(rect)
            self.mapView.setRegion(region, animated: true)
            self.mapView.overlays(in: .aboveLabels)

        }else {
            myRenders[activeNumber].strokeColor = .systemBlue
            activeNumber = activeNumber - 1
            myRenders[activeNumber].strokeColor = .blue
            let rect = self.myRoutes[activeNumber].boundingMapRect
            let region = MKCoordinateRegion(rect)
            self.mapView.setRegion(region, animated: true)
        }
        
        
    }
    @IBAction func nextRoute(_ sender: UIBarButtonItem) {
        let index = myRenders.count
    
        if activeNumber < index - 1 {
            myRenders[activeNumber].strokeColor = .systemBlue
            activeNumber = activeNumber + 1
            myRenders[activeNumber].strokeColor = .blue
            let rect = self.myRoutes[activeNumber].boundingMapRect
            let region = MKCoordinateRegion(rect)
            self.mapView.setRegion(region, animated: true)

        }else{
            myRenders[activeNumber].strokeColor = .systemBlue
            activeNumber = 0
            myRenders[activeNumber].strokeColor = .blue
            let rect = self.myRoutes[activeNumber].boundingMapRect
            let region = MKCoordinateRegion(rect)
            self.mapView.setRegion(region, animated: true)
        }
        
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        currentCoordinate = coordinate
        print("latitude: \(coordinate.latitude)")
        print("longitude: \(coordinate.longitude)")

        mapView.setCenter(coordinate, animated: true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        myRenders.append(renderer)
        for renderer in myRenders{ // setting initial colors of routes
            if myRenders.count > 2 {
                //myRenders[0].strokeColor = .red
                myRenders[1].strokeColor = .systemBlue
                myRenders[2].strokeColor = .systemBlue
            }
            else{
                renderer.strokeColor = .blue
                //renderer.lineWidth = 15
            }
        }

        return renderer
    }
}

// MARK: - Long press gesture

extension MapViewController{
    
    func addLongGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPressGesture(_ :)))
        self.view.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        destinationCoordinate = coordinate

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pinned"
        mapView.addAnnotation(annotation)
    }
}

// MARK: - Location checker
extension MapViewController{
    func checkLocationPermission() {
        switch self.locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            locationManager.requestLocation()
        case .denied, .restricted:
            //popup gosterecegiz. go to settings butonuna basildiginda
            //kullaniciyi uygulamamizin settings sayfasina gonder
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }
}
