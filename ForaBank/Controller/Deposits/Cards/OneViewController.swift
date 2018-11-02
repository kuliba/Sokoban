//
//  OneViewController.swift
//  testTest
//
//  Created by Ilya Masalov on 25/10/2018.
//  Copyright © 2018 Ilya Masalov. All rights reserved.
//

import UIKit
import iCarousel
import DeviceKit

class OneViewController: UIViewController {
    
    weak var currentViewController: UIViewController?
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    static let iphone5Devices: [Device] = [.iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE,
                                           .simulator(.iPhone5), .simulator(.iPhone5c), .simulator(.iPhone5s), .simulator(.iPhoneSE)]
    
    static let xDevices: [Device] = [
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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    @IBOutlet var carousel: iCarousel!
    
    var offset: CGFloat = {
        if Device().isOneOf(xDevices) {
            return 100
        } else {
            return 75
        }
    }() // 75 - 7, se 7+ , 100 - xsmax
    
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
        self.addSubview(newViewController.view, toView: self.container!)
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
    
    var previousOffset: CGFloat = 0
    
    var items = ["Управление", "Выписка", "О карте"]
    
    override func viewDidLoad() {
        
        currentViewController = storyboard?.instantiateViewController(withIdentifier: "feed0")
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(currentViewController!)
        addSubview(self.currentViewController!.view, toView: self.container)
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleScroll(_:)), name: NSNotification.Name("TableViewScrolled"), object: nil)
        scrollView.isScrollEnabled = false
        
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .wheel
        carousel.bounces = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerHeight.constant = -offset
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TransitionToSecondViewController") {
            //let secondViewController = segue.destination as! TwoViewController
            // Pass data to secondViewController before the transition
  
        }
    }
    
    var lastScrollViewOffset: CGFloat = 0
}

private extension OneViewController {
    
    @objc func handleScroll(_ notification: Notification?) {
        
        
        
        let tableScrollView = notification?.userInfo?["tableView"] as? UIScrollView
        var currentOffset = tableScrollView?.contentOffset.y
        
        let distanceFromBottom = (tableScrollView?.contentSize.height ?? 0.0) - (currentOffset ?? 0.0)
        
        if previousOffset < (currentOffset ?? 0.0) && distanceFromBottom > (tableScrollView?.frame.size.height ?? 0.0) {
            if (currentOffset ?? 0.0) > header.frame.height - offset {
                currentOffset = header.frame.height - offset
            }
            
            
            
            
            scrollView.contentOffset.y -= previousOffset - (currentOffset ?? 0.0)
            
            
            
            
            previousOffset = currentOffset ?? 0.0
            
        } else {
            if previousOffset > (currentOffset ?? 0.0) {
                if (currentOffset ?? 0.0) < 0 {
                    currentOffset = 0
                }
                
                
                
                
                
                scrollView.contentOffset.y -= previousOffset - (currentOffset ?? 0.0)
                
                
                
                previousOffset = currentOffset ?? 0.0
            }
        }
        
        
        
        
        print(previousOffset, currentOffset!, lastScrollViewOffset)
        
        
    }
}

extension OneViewController: iCarouselDataSource, iCarouselDelegate {
    
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
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 100))
            itemView.backgroundColor = .clear
            
            label = UILabel(frame: itemView.bounds)
            
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.textColor = .white
            
            label.font = UIFont(name: "Roboto-Regular", size: 16)
            label.tag = 1
            itemView.addSubview(label)
            
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = "\(items[index])"
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if (option == .wrap) {
            return 0.0
        }
        
        if option == .arc {
            if Device().isOneOf(OneViewController.iphone5Devices) {
                return CGFloat(Double.pi) / 2.5 // 2.75 - if not authorized
            } else if Device().isOneOf(OneViewController.xDevices) {
                return CGFloat(Double.pi) / 3.25 // 3.5 - if not authorized
            } else {
                return CGFloat(Double.pi) / 3.25 // 3.5 - if not authorized
            }
        }
        
        if option == .radius {
            if Device().isOneOf(OneViewController.iphone5Devices) {
                return 800
            } else if Device().isOneOf(OneViewController.xDevices) {
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
        
    }
}
