//
//  PageViewController.swift
//  TestPageView
//
//  Created by JT Ma on 10/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit

public enum PageLoopStyle : Int {
    case none
    case lead
    case trail
    case circle
}

public class PageViewController: UIPageViewController {
    
    public var pageData = [String]()
    public var pageLoopStyle = PageLoopStyle.none
    public var pageViewControllers: [UIViewController] = [] {
        didSet(value) {
            self.setViewControllers(value, direction: .forward, animated: false, completion: {done in })
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()        
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.delegate = self
        
        let startingViewController: DataViewController = self.viewControllerAtIndex(0, storyboard: UIStoryboard(name: "Main", bundle: nil))!
        let viewControllers = [startingViewController]
        self.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        self.dataSource = self
        
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = pageData.count
    }
    
    fileprivate var currentPage: Int = 0
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        self.view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        pageControl.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        pageControl.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true

        pageControl.pageIndicatorTintColor = UIColor.orange
        pageControl.currentPageIndicatorTintColor = UIColor.brown
        return pageControl
    }()
}

// MARK: - Page View Controller Data Source

extension PageViewController: UIPageViewControllerDataSource {
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        dataViewController.dataObject = self.pageData[index]
        return dataViewController
    }
    
    func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return pageData.index(of: viewController.dataObject) ?? NSNotFound
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        
        if (index == 0) || (index == NSNotFound) {
            switch pageLoopStyle {
            case .none, .trail:
                return nil
            case .circle, .lead:
                index = self.pageData.count
            }
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageData.count {
            switch pageLoopStyle {
            case .none, .lead:
                return nil
            case .circle, .trail:
                index = 0
            }
        }
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
}

// MARK: - UIPageViewController delegate methods

extension PageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.viewControllers![0]
            let viewControllers = [currentViewController]
            self.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
            
            self.isDoubleSided = false
            return .min
        }
        
        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]
        
        let indexOfCurrentViewController = self.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.pageViewController(self, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.pageViewController(self, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
        
        return .mid
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let firstViewController = pendingViewControllers.first as? DataViewController else {
            return
        }
        currentPage = indexOfViewController(firstViewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            return
        }
        self.pageControl.currentPage = currentPage
    }
    
}
