/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import iCarousel
import DeviceKit

class OneOneViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var container: RoundedEdgeView!
    @IBOutlet var carousel: iCarousel!
    @IBOutlet weak var contentViewTop: NSLayoutConstraint!
    var previousIndex = -1
    
    weak var currentViewController: UIViewController?
    var previousOffset: CGFloat = 0
    var items = ["Управление", "Выписка", "О счете"]
    var labels = [UILabel?]()
    var lastScrollViewOffset: CGFloat = 0
    
    var offset: CGFloat = {
        if Device().isOneOf(Constants.xDevices) {
            return 100 // models: x
        } else {
            return 75 // models 7 7+ se
        }
    }()
    
    // MARK: - Actions
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        currentViewController = storyboard?.instantiateViewController(withIdentifier: "feedfeed0")
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(currentViewController!)
        addSubview(self.currentViewController!.view, toView: self.container)
        
        labels = [UILabel?].init(repeating: nil, count: items.count)

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

private extension OneOneViewController {
    
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
//            UIView.animate(withDuration: 0.1, delay: 0, options: .beginFromCurrentState, animations: {
                self.contentViewTop.constant += self.previousOffset - currentOffset
                self.previousOffset = currentOffset
//                self.view.layoutIfNeeded()
//            }, completion: nil)
            
            
        } else {
            if previousOffset > currentOffset {
                if currentOffset < 0 {
                    currentOffset = 0
                }
//                UIView.animate(withDuration: 0.1, delay: 0, options: .beginFromCurrentState, animations: {
                    self.contentViewTop.constant += self.previousOffset - currentOffset
                    self.previousOffset = currentOffset
//                    self.view.layoutIfNeeded()
//                }, completion: nil)
            }
        }
        container.setNeedsDisplay()
    }
    
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
        let newViewController = storyboard?.instantiateViewController(withIdentifier: "feedfeed\(index)")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController: currentViewController!, toViewController: newViewController!)
        currentViewController = newViewController
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParent: nil)
        addChild(newViewController)
        addSubview(newViewController.view, toView: container!)
        // TODO: Set the starting state of your constraints here
        newViewController.view.alpha = 0
        newViewController.view.bounds.origin.y -= 10
        newViewController.view.layoutIfNeeded()
        // TODO: Set the ending state of your constraints here
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
            self.contentViewTop.constant = 0
            self.previousOffset = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
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
                NotificationCenter.default.addObserver(self, selector: #selector(self.handleScroll(_:)), name: NSNotification.Name("TableViewScrolled"), object: nil)
            })
        })
    }
}

extension OneOneViewController: iCarouselDataSource, iCarouselDelegate {
    
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
            label.font = UIFont(name: "Roboto-Light", size: 16)
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
        labels[previousIndex]?.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        labels[previousIndex]?.font = UIFont(name: "Roboto-Light", size: 16)
        
        labels[index]?.textColor = .white
        labels[index]?.font = UIFont(name: "Roboto-Regular", size: 16)
        previousIndex = index
        showComponent(index: index)
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        if previousIndex<0 || previousIndex == carousel.currentItemIndex{
            previousIndex = carousel.currentItemIndex
            labels[carousel.currentItemIndex]?.textColor = .white
            labels[carousel.currentItemIndex]?.font = UIFont(name: "Roboto-Regular", size: 16)
            return
        }
        labels[previousIndex]?.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        labels[previousIndex]?.font = UIFont(name: "Roboto-Light", size: 16)
        labels[carousel.currentItemIndex]?.textColor = .white
        labels[carousel.currentItemIndex]?.font = UIFont(name: "Roboto-Regular", size: 16)
        previousIndex = carousel.currentItemIndex
        showComponent(index: carousel.currentItemIndex)
    }
}

extension OneOneViewController: CustomTransitionOriginator, CustomTransitionDestination {
    var fromAnimatedSubviews: [String : UIView] {
//        print("OneOneViewController fromAnimatedSubviews")
        var views = [String : UIView]()
        let tableSnapshot = view.snapshotView(afterScreenUpdates: true)!
        let rectMask = CAShapeLayer()
        tableSnapshot.layer.mask = rectMask

        let rectPath = CGPath(rect: CGRect(x: 0, y: container.frame.origin.y+33, width: tableSnapshot.frame.width, height: container.frame.height), transform: nil)
        rectMask.path = rectPath
        views["tableView"] = tableSnapshot
        
        let containerSnapshot = container.snapshotView(afterScreenUpdates: true)!
        containerSnapshot.frame = view.convert(container.frame , from: view)
        views["container"] = containerSnapshot
        
        guard let c = currentViewController as? CustomTransitionOriginator else {
//            print("OneOneViewController guard return")
            return views
        }
        views.merge(c.fromAnimatedSubviews, uniquingKeysWith: { (first, _) in first })
//        print("OneOneViewController views merged")
        return views
    }
    
    var toAnimatedSubviews: [String : UIView] {
//        print("OneOneViewController toAnimatedSubviews")
        var views = [String : UIView]()
//        views["header"] = header
        let tableSnapshot = view.snapshotView(afterScreenUpdates: true)!
        let rectMask = CAShapeLayer()
        tableSnapshot.layer.mask = rectMask

        let rectPath = CGPath(rect: CGRect(x: 0, y: container.frame.origin.y+33, width: tableSnapshot.frame.width, height: container.frame.height), transform: nil)
        rectMask.path = rectPath
        views["tableView"] = tableSnapshot
        
        let containerSnapshot = container.snapshotView(afterScreenUpdates: true)!
        containerSnapshot.frame = view.convert(container.frame , from: view)
        views["container"] = containerSnapshot
        
        guard let c = currentViewController as? CustomTransitionDestination else {
//            print("OneOneViewController guard return")
            return views
        }
        views.merge(c.toAnimatedSubviews, uniquingKeysWith: { (first, _) in first })
//        print("OneOneViewController views merged")
        return views
    }
}
