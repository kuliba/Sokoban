//
//  OneViewController.swift
//  testTest
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 25/10/2018.
//  Copyright © 2018 Ilya Masalov. All rights reserved.
//

import UIKit
import iCarousel
import DeviceKit

class OneViewController: UIViewController {
    
    // MARK: - Properties
//    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet var carousel: iCarousel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewTop: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    var offset: CGFloat = {
        if Device().isOneOf(Constants.xDevices) {
            return 100 // models: x
        } else {
            return 75 // models 7 7+ se
        }
    }()
    
    weak var currentViewController: UIViewController?
    
    var previousOffset: CGFloat = 0
    
    var items = ["Управление", "Выписка", "О карте"]
    
    var lastScrollViewOffset: CGFloat = 0
    
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        currentViewController = storyboard?.instantiateViewController(withIdentifier: "feed0")
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(currentViewController!)
        addSubview(self.currentViewController!.view, toView: self.container)
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleScroll(_:)), name: NSNotification.Name("TableViewScrolled"), object: nil)
        
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .wheel
        carousel.bounces = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransitionToSecondViewController" {
            //let secondViewController = segue.destination as! TwoViewController
            // Pass data to secondViewController before the transition
        }
    }
}

private extension OneViewController {
    
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
        NotificationCenter.default.removeObserver(self)
        let newViewController = storyboard?.instantiateViewController(withIdentifier: "feed\(index)")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        currentViewController = newViewController
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
            self.contentViewTop.constant = 0
            self.previousOffset = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                newViewController.view.alpha = 1
                newViewController.view.bounds.origin.y += 10
            }, completion: { _ in
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParent()
                newViewController.didMove(toParent: self)
                NotificationCenter.default.addObserver(self, selector: #selector(self.handleScroll(_:)), name: NSNotification.Name("TableViewScrolled"), object: nil)
            })
        })
    }
    
    @objc func handleScroll(_ notification: Notification?) {
        guard let tableScrollView = notification?.userInfo?["tableView"] as? UIScrollView else {
            return
        }
        var currentOffset = tableScrollView.contentOffset.y
        
        let distanceFromBottom = tableScrollView.contentSize.height - currentOffset
        if previousOffset < currentOffset && distanceFromBottom > tableScrollView.frame.size.height {
            if currentOffset > header.frame.height - offset {
                currentOffset = header.frame.height - offset
            }
            UIView.animate(withDuration: 0.1, delay: 0, options: .beginFromCurrentState, animations: {
                self.contentViewTop.constant += self.previousOffset - currentOffset
                self.previousOffset = currentOffset
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            
        } else {
            if previousOffset > currentOffset {
                if currentOffset < 0 {
                    currentOffset = 0
                }
                UIView.animate(withDuration: 0.1, delay: 0, options: .beginFromCurrentState, animations: {
                    self.contentViewTop.constant += self.previousOffset - currentOffset
                    self.previousOffset = currentOffset
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
        container.setNeedsDisplay()
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
            if Device().isOneOf(Constants.iphone5Devices) {
                return CGFloat(Double.pi) / 2.5 // 2.75 - if not authorized
            } else if Device().isOneOf(Constants.xDevices) {
                return CGFloat(Double.pi) / 3.25 // 3.5 - if not authorized
            } else {
                return CGFloat(Double.pi) / 3.25 // 3.5 - if not authorized
            }
        }
        
        if option == .radius {
            if Device().isOneOf(Constants.iphone5Devices) {
                return 800
            } else if Device().isOneOf(Constants.xDevices) {
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
