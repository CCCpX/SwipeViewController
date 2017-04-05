//
//  ViewController.swift
//  SwipeViewControllers
//
//  Created by CPX on 05/04/2017.
//  Copyright © 2017 CPX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var navigationTitle = [String]()
    var viewControllerArray = [UIViewController]()
    
    private var contentView: UIView!
    
    private var navigationView: UIView!
    private var pageController: UIPageViewController!
    fileprivate var indicatorView: UIView!
    private var pageScrollView: UIScrollView!
    
    fileprivate var currentIndex = 0
    
    fileprivate var isPageScrolling = false
    fileprivate var hasAppeared = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        contentView = UIView(frame: CGRect(x: 0, y: 90, width: view.bounds.width, height: view.bounds.width))
        view.addSubview(contentView)
        for _ in 0...3 {
            let contentVC = UIViewController()
            let randomValue = CGFloat(drand48())
            contentVC.view.backgroundColor = UIColor(red: randomValue, green: randomValue, blue: randomValue, alpha: 1)
            viewControllerArray.append(contentVC)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !hasAppeared {
            setUpPageViewController()
            setUpNavigationView()
            hasAppeared = true
        }
    }
    
    func setUpNavigationView() {
        navigationView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        if navigationTitle.count == 0 {
            navigationTitle = ["Title0", "Title1", "Title2", "Title3"]
        }
        let vcCount = viewControllerArray.count
        for index in 0..<viewControllerArray.count {
            
            let button = UIButton(frame: CGRect(x: index*Int(view.bounds.width)/vcCount, y: 0, width: Int(view.bounds.width)/vcCount, height: 44))
            navigationView.addSubview(button)
            button.tag = index
            button.backgroundColor = index%2 == 0 ? .yellow : .cyan
            button.addTarget(self, action: #selector(ViewController.tapNavigationButtonAction(sender:)), for: .touchUpInside)
            button.setTitle(navigationTitle[index], for: .normal)
        }
        contentView.addSubview(navigationView)
        
        setUpIndicatorView()
    }
    
    func setUpIndicatorView() {
        indicatorView = UIView(frame: CGRect(x: 0, y: 41, width: Int(view.bounds.width)/viewControllerArray.count, height: 3))
        indicatorView.backgroundColor = .green
        navigationView.addSubview(indicatorView)
    }
    
    func setUpPageViewController() {
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.view.frame = CGRect(x: 0, y: 44, width: contentView.bounds.width, height: contentView.bounds.height-44)
        pageController.delegate = self
        pageController.dataSource = self
        pageController.setViewControllers([viewControllerArray[0]], direction: .forward, animated: true, completion: nil)
        addChildViewController(pageController)
        contentView.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
        syncScrollView()
    }
    
    func syncScrollView() {
        for view in pageController.view.subviews {
            if view.isKind(of: UIScrollView.self) {
                pageScrollView = view as? UIScrollView
                pageScrollView.delegate = self
            }
        }
    }
    
    func tapNavigationButtonAction(sender: UIButton) {
        if !isPageScrolling {
            if sender.tag > currentIndex {
                for index in currentIndex...sender.tag {
                    pageController.setViewControllers([viewControllerArray[index]], direction: .forward, animated: true, completion: { [weak self] complete in
                        if complete {
                            self?.currentIndex = index
                        }
                    })
                }
            } else if sender.tag < currentIndex {
                for index in (sender.tag...currentIndex).reversed() {
                    pageController.setViewControllers([viewControllerArray[index]], direction: .reverse, animated: true, completion: { [weak self] complete in
                        if complete {
                            self?.currentIndex = index
                        }
                    })
                }
            }
        }
    }
    
}

extension ViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewControllerArray.index(of: viewController)
        if var index = index {
            index += 1
            if index == viewControllerArray.count {
                return nil
            }
            return viewControllerArray[index]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = viewControllerArray.index(of: viewController)
        if var index = index, index > 0{
            index -= 1
            return viewControllerArray[index]
        } else {
            return nil
        }
    }
}

extension ViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let last = pageViewController.viewControllers?.last
            if let lastVC = last {
                currentIndex = viewControllerArray.index(of: lastVC)!
            }
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let xFromCenter = view.bounds.width - scrollView.contentOffset.x
        let xCoor = Int(indicatorView.bounds.width) * currentIndex
        indicatorView.frame = CGRect(x: CGFloat(xCoor-Int(xFromCenter)/viewControllerArray.count), y: indicatorView.frame.origin.y, width: indicatorView.frame.size.width, height: indicatorView.frame.size.height)
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isPageScrolling = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isPageScrolling = false
    }
}

