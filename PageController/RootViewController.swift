//
//  RootViewController.swift
//  TestPageView
//
//  Created by JT Ma on 10/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    var pageViewController: PageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//        let startingViewController = self.storyboard!.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
//        let viewControllers = [startingViewController]
//        self.pageViewController.pageViewControllers = viewControllers
        
        // Create the data model.
        let dateFormatter = DateFormatter()
        self.pageViewController.pageData = dateFormatter.weekdaySymbols
        self.pageViewController.pageLoopStyle = .circle
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController.view.frame = pageViewRect
        self.pageViewController.didMove(toParentViewController: self)
     }
}
