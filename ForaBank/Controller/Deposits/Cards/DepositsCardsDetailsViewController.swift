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
import Hero

protocol TabCardDetailViewController {
    func set(card:Card?)
}

class DepositsCardsDetailsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet var carousel: iCarousel!
    @IBOutlet weak var contentViewTop: NSLayoutConstraint!
    @IBOutlet weak var cardView: DetailedCardView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var previousIndex = -1
    
    var card: Card? = nil

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
    var labels = [UILabel?]()
    var lastScrollViewOffset: CGFloat = 0
    
    var selectedTabColor: UIColor = .white
    var tabColor: UIColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)

    var segueId: String? = nil
    var backSegueId: String? = nil
    
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        if let card = card {
            cardView.update(withCard: card)
            cardView.backgroundImageView.alpha = 0
            backgroundImageView.image = UIImage(named: card.type.rawValue)
            cardView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
            if card.type == .mastercard {
                let blackView = UIView()
                blackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
                blackView.translatesAutoresizingMaskIntoConstraints = false
                backgroundImageView.addSubview(blackView)
                backgroundImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[b]-0-|", options: [], metrics: nil, views: ["b":blackView]))
                backgroundImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[b]-0-|", options: [], metrics: nil, views: ["b":blackView]))
//                cardView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
//                selectedTabColor = .black
//                tabColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
                cardView.foregroundColor = .white
            }
            cardView.layer.cornerRadius = 10
        }
        currentViewController = storyboard?.instantiateViewController(withIdentifier: "feed0")
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(currentViewController!)
        if let c = currentViewController as? TabCardDetailViewController {
            c.set(card: card)
        }
        addSubview(self.currentViewController!.view, toView: self.container)
        
        labels = [UILabel?].init(repeating: nil, count: items.count)

        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleScroll(_:)), name: NSNotification.Name("TableViewScrolled"), object: nil)
        
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .wheel
        carousel.bounces = false
        
        hero.isEnabled = true
        hero.modalAnimationType = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segueId == "DepositsCardsDetailsViewController" {
//            view.hero.id = "view"
//            view.hero.modifiers = [
//                HeroModifier.duration(2),
//                HeroModifier.opacity(0),
//                HeroModifier.fade
//            ]
//            cardView.hero.id = "card"
//            cardView.hero.modifiers = [
//                HeroModifier.duration(2),
//                HeroModifier.zPosition(2)
//            ]
//            header.hero.id = "background"
//            header.hero.modifiers = [
//                HeroModifier.duration(2),
//                HeroModifier.zPosition(0),
//                HeroModifier.opacity(0)
//            ]
//            container.hero.id = "content"
//            container.hero.modifiers = [
//                HeroModifier.duration(2),
//                HeroModifier.zPosition(1)
//            ]
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardView.hero.id = nil
        header.hero.id = nil
        container.hero.id = nil
        view.hero.id = nil
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransitionToSecondViewController" {
            //let secondViewController = segue.destination as! TwoViewController
            // Pass data to secondViewController before the transition
        }
    }
}

private extension DepositsCardsDetailsViewController {
    
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
        if let c = newViewController as? TabCardDetailViewController {
            c.set(card: card)
        }
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

extension DepositsCardsDetailsViewController: iCarouselDataSource, iCarouselDelegate {
    
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
            label.textColor = tabColor
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
        labels[previousIndex]?.textColor = tabColor
        labels[previousIndex]?.font = UIFont(name: "Roboto-Light", size: 16)
        
        labels[index]?.textColor = selectedTabColor
        labels[index]?.font = UIFont(name: "Roboto-Regular", size: 16)
        previousIndex = index
        showComponent(index: index)
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        if previousIndex<0 || previousIndex == carousel.currentItemIndex{
            previousIndex = carousel.currentItemIndex
            labels[carousel.currentItemIndex]?.textColor = selectedTabColor
            labels[carousel.currentItemIndex]?.font = UIFont(name: "Roboto-Regular", size: 16)
            return
        }
        labels[previousIndex]?.textColor = tabColor
        labels[previousIndex]?.font = UIFont(name: "Roboto-Light", size: 16)
        labels[carousel.currentItemIndex]?.textColor = selectedTabColor
        labels[carousel.currentItemIndex]?.font = UIFont(name: "Roboto-Regular", size: 16)
        previousIndex = carousel.currentItemIndex
        showComponent(index: carousel.currentItemIndex)
    }
}
