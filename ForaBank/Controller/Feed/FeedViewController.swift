//
//  FeedViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov on 09/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import iCarousel
import DeviceKit

class FeedViewController: UIViewController {
    
    var gradientViews = [GradientView2]()
    
    func addGradients() {
        for gradient in [
            (UIColor(hexFromString: "EA4644"), UIColor(hexFromString: "F1AD72")),
            (UIColor(hexFromString: "F1AD72"), UIColor(hexFromString: "EA4544")),
            (UIColor(hexFromString: "EA4544"), UIColor(hexFromString: "F1AD72")),
            (UIColor(hexFromString: "F1AD72"), UIColor(hexFromString: "EA4544")),
            (UIColor(hexFromString: "EA4544"), UIColor(hexFromString: "F1AD72"))
            ] {
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
    
    
    
    
    let iphone5Devices: [Device] = [.iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE,
                                    .simulator(.iPhone5), .simulator(.iPhone5c), .simulator(.iPhone5s), .simulator(.iPhoneSE)]
    
    let xDevices: [Device] = [
        .iPhoneX,
        .iPhoneX,
        .iPhoneXr,
        .iPhoneXs,
        .iPhoneXsMax,
        
        .simulator(.iPhoneX),
        .simulator(.iPhoneX),
        .simulator(.iPhoneXr),
        .simulator(.iPhoneXs),
        .simulator(.iPhoneXsMax)
    ]
    
    @IBOutlet var carousel: iCarousel!
    @IBOutlet weak var containerView: UIView!
    weak var currentViewController: UIViewController?
    
    var items = ["Текущее", "Предстоящее", "Предложения", "Информация", "Настройки"]
    
    
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
    
    func showComponent(index: Int) {
        
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "feed\(index)")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController
        
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParent: nil)
        self.addChild(newViewController)
        self.addSubview(newViewController.view, toView:self.containerView!)
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
    
    override func viewDidLoad() {
        currentViewController = storyboard?.instantiateViewController(withIdentifier: "feed0")
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(currentViewController!)
        addSubview(self.currentViewController!.view, toView: self.containerView)
        
        super.viewDidLoad()
        
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .wheel
        carousel.bounces = false
        // carousel.isPagingEnabled = true
        // carousel.isScrollEnabled = false
        
        addGradients()
        gradientViews[0].alpha = 1
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
            label.textColor = .white
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
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if (option == .wrap) {
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
        showComponent(index: index)
        for (i, n) in gradientViews.enumerated() {
            UIView.animate(withDuration: 0.25, animations: {
                n.alpha = index == i ? 1 : 0
            })
        }
    }
}
