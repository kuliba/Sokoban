//
//  FeedViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 09/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import iCarousel
import DeviceKit

class FeedViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var carousel: iCarousel!
    @IBOutlet weak var containerView: UIView!
    
    lazy var leftSwipeRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        recognizer.direction = .left
        return recognizer
    }()
    lazy var rightSwipeRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        recognizer.direction = .right
        return recognizer
    }()
    var previousIndex = -1
    
    var labels = [UILabel?]()
    var gradientViews = [GradientView2]()
    
    let iphone5Devices = Constants.iphone5Devices
    let xDevices = Constants.xDevices
    
    weak var currentViewController: UIViewController?
    
    var items = ["Текущее", "Предстоящее", "Предложения", "Информация", "Настройки"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        currentViewController = storyboard?.instantiateViewController(withIdentifier: "feed2")
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(currentViewController!)
        addSubview(self.currentViewController!.view, toView: self.containerView)
        
        labels = [UILabel?].init(repeating: nil, count: items.count)
        super.viewDidLoad()
        
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .wheel
        carousel.bounces = false
        // carousel.isPagingEnabled = true
        // carousel.isScrollEnabled = false
        //carousel.currentItemIndex = 2
        carousel.scrollToItem(at: 2, animated: false)
        addGradients()
        gradientViews[0].alpha = 1
        
        containerView.addGestureRecognizer(leftSwipeRecognizer)
        containerView.addGestureRecognizer(rightSwipeRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if Device().isOneOf(xDevices) {
            carousel.frame.size.height = 120
        } else {
            carousel.frame.size.height = 90
        }
    }
}

// MARK: - iCarousel Delegate and DataSource
extension FeedViewController: iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            //get a reference to the label in the recycled view
            label = itemView.viewWithTag(1) as! UILabel
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
            itemView.backgroundColor = .clear
            
            label = UILabel(frame: itemView.bounds)
            
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
            label.font = UIFont(name: "Roboto-Regular", size: 16)
            label.tag = 1
            itemView.addSubview(label)
        }
        
        // set item label
        // remember to always set any properties of your carousel item
        // views outside of the `if (view == nil) {...}` check otherwise
        // you'll get weird issues with carousel item content appearing
        // in the wrong place in the carousel
        label.text = "\(items[index])"
        labels[index] = label
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if option == .wrap {
            return 0.0
        }
        
        if option == .arc {
            if Device().isOneOf(iphone5Devices) {
                return CGFloat(Double.pi) / 1.75 // 2.75 - if not authorized
            } else if Device().isOneOf(xDevices) {
                return CGFloat(Double.pi) / 2.5 // 3.5 - if not authorized
            } else {
                return CGFloat(Double.pi) / 2.5 // 3.5 - if not authorized
            }
        }
        
        if option == .radius {
            if Device().isOneOf(iphone5Devices) {
                return 800
            } else if Device().isOneOf(xDevices) {
                return 1300
            } else {
                return 1300
            }
        }
        
        return value
    }
    
    func numberOfPlaceholders(in carousel: iCarousel) -> Int {
        return 6
    }
    
    func carousel(_ carousel: iCarousel, placeholderViewAt index: Int, reusing view: UIView?) -> UIView {
        return UIView()
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        labels[previousIndex]?.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        labels[index]?.textColor = .white
        previousIndex = index
        showComponent(index: index)
        for (i, n) in gradientViews.enumerated() {
            UIView.animate(withDuration: 0.25, animations: {
                n.alpha = index == i ? 1 : 0
            })
        }
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        if previousIndex<0 || previousIndex == carousel.currentItemIndex{
            previousIndex = carousel.currentItemIndex
            labels[carousel.currentItemIndex]?.textColor = .white
            return
        }
        labels[previousIndex]?.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        labels[carousel.currentItemIndex]?.textColor = .white
        previousIndex = carousel.currentItemIndex
        showComponent(index: carousel.currentItemIndex)
        for (i, n) in gradientViews.enumerated() {
            UIView.animate(withDuration: 0.25, animations: {
                n.alpha = carousel.currentItemIndex == i ? 1 : 0
            })
        }
    }
}

// MARK: - Private methods
private extension FeedViewController {
    func addSubview(_ subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                           options: [], metrics: nil, views: viewBindingsDict
        ))
        
        parentView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                           options: [], metrics: nil, views: viewBindingsDict
        ))
    }
    
    func addGradients() {
        let gradients = [
            (UIColor(hexFromString: "EA4644"), UIColor(hexFromString: "F1AD72")),
            (UIColor(hexFromString: "F1AD72"), UIColor(hexFromString: "EA4544")),
            (UIColor(hexFromString: "EA4544"), UIColor(hexFromString: "F1AD72")),
            (UIColor(hexFromString: "F1AD72"), UIColor(hexFromString: "EA4544")),
            (UIColor(hexFromString: "EA4544"), UIColor(hexFromString: "F1AD72"))
        ]
        
        for gradient in gradients {
            let v = GradientView2()
            v.color1 = gradient.0
            v.color2 = gradient.1
            v.alpha = 0
            v.frame = view.frame
            v.addGradientView()
            v.layoutIfNeeded()
            gradientViews.append(v)
            view.insertSubview(v, at: 0)
        }
    }
    
    func showComponent(index: Int) {
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "feed\(index)")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        currentViewController = newViewController
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParent: nil)
        addChild(newViewController)
        addSubview(newViewController.view, toView:self.containerView!)
        // TODO: Set the starting state of your constraints here
        newViewController.view.alpha = 0
        newViewController.view.bounds.origin.y -= 10
        
        newViewController.view.layoutIfNeeded()
        
        // TODO: Set the ending state of your constraints here
        
        UIView.animate(withDuration: 0.25, animations: {
            oldViewController.view.alpha = 0
            oldViewController.view.bounds.origin.y -= 10
            // only need to call layoutIfNeeded here
            newViewController.view.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                newViewController.view.alpha = 1
                newViewController.view.bounds.origin.y += 10
            }, completion: { _ in
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParent()
                newViewController.didMove(toParent: self)
            })
        })
    }
    
    @objc func swipeAction(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if carousel.currentItemIndex < carousel.numberOfItems-1 {
                carousel.scrollToItem(at: carousel.currentItemIndex+1, animated: true)
            }
        } else if gesture.direction == .right {
            if carousel.currentItemIndex > 0 {
                carousel.scrollToItem(at: carousel.currentItemIndex-1, animated: true)
            }
        }
    }
}
