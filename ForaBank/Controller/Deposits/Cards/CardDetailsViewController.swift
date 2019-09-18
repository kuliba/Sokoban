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
import Hero

protocol TabCardDetailViewController {
    func set(card: Card?)
}

class CardDetailsViewController: UIViewController {

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
            if card.number?.prefix(6) == "465626" {
                backgroundImageView.image = UIImage(named: "card_visa_gold")
            }
            if card.number?.prefix(6) == "457825" {
                backgroundImageView.image = UIImage(named: "card_visa_platinum")
            }
            if card.number?.prefix(6) == "425690" {
                backgroundImageView.image = UIImage(named: "card_visa_debet")
            }
            if card.number?.prefix(6) == "557986" {
                backgroundImageView.image = UIImage(named: "card_visa_standart")
            }
            if card.number?.prefix(6) == "536466" {
                backgroundImageView.image = UIImage(named: "card_visa_virtual")
            }
            if card.number?.prefix(6) == "470336" {
                backgroundImageView.image = UIImage(named: "card_visa_infinity")
            }
            cardView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
            if card.type == .mastercard {
                let blackView = UIView()
                blackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
                blackView.translatesAutoresizingMaskIntoConstraints = false
                backgroundImageView.addSubview(blackView)
                backgroundImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[b]-0-|", options: [], metrics: nil, views: ["b": blackView]))
                backgroundImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[b]-0-|", options: [], metrics: nil, views: ["b": blackView]))

//                selectedTabColor = .black
//                tabColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
                cardView.foregroundColor = .white
            }
            cardView.layer.cornerRadius = 10
        }
        let managementVC = storyboard?.instantiateViewController(withIdentifier: "ProductManagementViewController") as? ProductManagementViewController
        managementVC?.actionsType = "card"
        currentViewController = managementVC
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
        if segueId == "CardDetailsViewController" {
            cardView.hero.id = "card"
            cardView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.forceNonFade,
                HeroModifier.zPosition(11),
                HeroModifier.useNormalSnapshot
            ]
            container.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(2)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.forceNonFade,
                HeroModifier.opacity(1)
            ]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardView.hero.id = nil
        cardView.hero.modifiers = nil
        container.hero.modifiers = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "CardDetailsViewController" {
            cardView.hero.id = "card"
            cardView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(1),
                HeroModifier.forceNonFade,
                HeroModifier.zPosition(11),
                HeroModifier.useNormalSnapshot
            ]
            container.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(2)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.forceNonFade,
                HeroModifier.opacity(0)
            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cardView.hero.id = nil
        cardView.hero.modifiers = nil
        container.hero.modifiers = nil
    }




}

private extension CardDetailsViewController {

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

    func addSubview(_ subView: UIView, toView parentView: UIView) {
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

        let newViewController: UIViewController?

        switch index {
        case 0:
            let managementVC = storyboard?.instantiateViewController(withIdentifier: "ProductManagementViewController") as? ProductManagementViewController
            managementVC?.actionsType = "card"
            newViewController = managementVC
        case 2:
            let managementVC = storyboard?.instantiateViewController(withIdentifier: "ProductAboutViewController") as? ProductAboutViewController
            managementVC?.items = card?.getProductAbout()
            newViewController = managementVC
        default:
            newViewController = storyboard?.instantiateViewController(withIdentifier: "feed\(index)")
        }

        guard let nonNilNewVC = newViewController else {
            return
        }
        nonNilNewVC.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController: currentViewController!, toViewController: nonNilNewVC)
        currentViewController = nonNilNewVC
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

extension CardDetailsViewController: iCarouselDataSource, iCarouselDelegate {

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
        if previousIndex < 0 || previousIndex == carousel.currentItemIndex {
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
