//
//  BannerSlider.swift
//  UIComponents
//
//  Created by Bilal on 21.01.2022.
//

import UIKit

class BannerSlider: UIViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView(frame: CGRect(x:50, y:100, width:320,height: 300))
    var colors:[UIColor] = [UIColor.red, UIColor.blue, UIColor.green, UIColor.systemPink, UIColor.yellow]
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    var pageControl : UIPageControl = UIPageControl(frame: CGRect(x:100,y: 400, width:200, height:50))
    var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurePageControl()

        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        

        self.view.addSubview(scrollView)
        for index in 0..<5 {

            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size

            let subView = UIView(frame: frame)
            subView.backgroundColor = colors[index]
            self.scrollView.addSubview(subView)
        }

        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width * 5,height: self.scrollView.frame.size.height)
        timerStart()
    }
    
    // MARK: - Timer Settings
    @objc func dummy(){
        scrollView.contentOffset.x = scrollView.contentOffset.x + 320
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    func timerStart(){
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(dummy), userInfo: nil, repeats: true)
    }
    func timerStop(){

        timer?.invalidate()
    }
    
    // MARK: - pageControl Config
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.numberOfPages = colors.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.black
        self.pageControl.currentPageIndicatorTintColor = UIColor.green
        self.view.addSubview(pageControl)
    }

    // MARK: - ScrollView Delegates

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { //update pageController current page

        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // view rearrangements

        if Int(scrollView.contentOffset.x) < 0 { // firstView to lastView
            
            scrollView.contentOffset.x = CGFloat(1280)
            
        }else if Int(scrollView.contentOffset.x) > 1280 { // lastView to firstView
            
            scrollView.contentOffset.x = 0
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        timerStop()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        timerStart()
    }
}

