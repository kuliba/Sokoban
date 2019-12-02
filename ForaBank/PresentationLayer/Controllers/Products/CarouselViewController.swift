/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищен.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import DeviceKit
import iCarousel
import Hero
import ReSwift

class CarouselViewController: UIViewController, StoreSubscriber {

    // MARK: - Properties
    @IBOutlet var carousel: iCarousel!
    @IBOutlet weak var containerView: RoundedEdgeView!
    @IBOutlet weak var carouselMaskCenterVerticalyConstraint: NSLayoutConstraint!

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

    let gradientView = GradientView()
    let gradients = [
        [UIColor(hexFromString: "EF4136")!, UIColor(hexFromString: "EF4136")!],
        [UIColor(hexFromString: "EF4136")!, UIColor(hexFromString: "EF4136")!],
        [UIColor(hexFromString: "EF4136")!, UIColor(hexFromString: "EF4136")!],
        [UIColor(hexFromString: "EF4136")!, UIColor(hexFromString: "EF4136")!],
        [UIColor(hexFromString: "EF4136")!, UIColor(hexFromString: "EF4136")!],
        [UIColor(hexFromString: "EF4136")!, UIColor(hexFromString: "EF4136")!]
    ]
    let browDevices = Constants.browDevices
    weak var currentViewController: UIViewController?
    var router: ProductsNavigator?
    var labels = [UILabel?]()
    var menuItems: Array<AnyHashable> {
        get {
            return Array<AnyHashable>(dynamicMenuItems) + Array<AnyHashable>(staticMenuItems)
        }
    }
    var dynamicMenuItems: Array<ProductType> = [ProductType.card, ProductType.account, ProductType.deposit, ProductType.loan]
    var staticMenuItems: Array<String> = ["История"]
    var segueId: String? = nil
    var backSegueId: String? = nil



    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        currentViewController = storyboard?.instantiateViewController(withIdentifier: "DepositsCardsListViewController")
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(currentViewController!)
        addSubview(self.currentViewController!.view, toView: self.containerView)

        labels = [UILabel?].init(repeating: nil, count: menuItems.count)

        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .wheel
        carousel.bounces = false
        // carousel.isPagingEnabled = true
        // carousel.isScrollEnabled = false

        gradientView.frame = view.frame
        gradientView.color1 = gradients[0][0]
        gradientView.color2 = gradients[0][1]
        view.insertSubview(gradientView, at: 0)
        containerView.addGestureRecognizer(leftSwipeRecognizer)
        containerView.addGestureRecognizer(rightSwipeRecognizer)

        hero.isEnabled = true
        hero.modalAnimationType = .none
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let isBrowDevice = Device.current.isOneOf(browDevices)
        carousel.frame.size.height = isBrowDevice ? 120 : 90
        carouselMaskCenterVerticalyConstraint.constant = isBrowDevice ? 22 : 7
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segueId == "CardDetailsViewController" {
            gradientView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(1)
                ]),
                HeroModifier.duration(0.25),
                HeroModifier.opacity(0),
            ]
            carousel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(1)
                ]),
                HeroModifier.duration(0.25),
                HeroModifier.opacity(0)
            ]
            containerView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(3)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 0, y: containerView.frame.height)),
                HeroModifier.forceNonFade,
                HeroModifier.zPosition(0)
            ]

        } else {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.3),
                HeroModifier.delay(0.2),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.beginWith([HeroModifier.opacity(1)]),
                HeroModifier.duration(0.5),
                //            HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
            containerView.hero.id = "content"
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil

        store.subscribe(self) { state in
            state.select { $0.productsState }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "CardDetailsViewController" {
            gradientView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(1)
                ]),
                HeroModifier.duration(0.25),
                HeroModifier.opacity(0),
            ]
            carousel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(1)
                ]),
                HeroModifier.duration(0.25),
                HeroModifier.opacity(0)
            ]
            containerView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(3)
                ]),
                HeroModifier.duration(0.5),
                HeroModifier.translate(x: 0, y: containerView.frame.height, z: 1),
                HeroModifier.forceNonFade,
                HeroModifier.zPosition(0)
            ]

        } else {
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
            containerView.hero.id = "content"
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gradientView.hero.modifiers = nil
        carousel.hero.modifiers = nil
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil

        store.unsubscribe(self)
    }

    func newState(state: ProductState) {
        if menuItems.count == staticMenuItems.count {
            var productTypesSet = Set<ProductType>()
            state.products?.forEach { productTypesSet.insert($0.productType) }

            dynamicMenuItems = Array<ProductType>(productTypesSet).sorted { $0 < $1 }
            updateCrousel()
        }
    }
}

extension CarouselViewController {
    private func updateCrousel() {
        labels = [UILabel?].init(repeating: nil, count: menuItems.count)
        carousel.reloadData()
    }
}

extension CarouselViewController: iCarouselDataSource, iCarouselDelegate {

    func numberOfItems(in carousel: iCarousel) -> Int {
        return menuItems.count
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel

        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))

            label.backgroundColor = .clear
            label.textAlignment = .center
            label.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
            label.font = UIFont(name: "Roboto-Light", size: 16)
            label.tag = 1
        }
        if let title = menuItems[index] as? ProductType {
            label.text = "\(title.localizedListName)"
        } else if let title = menuItems[index] as? String {
            label.text = title
        }
        labels[index] = label

        return label
    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {

        if option == .wrap {
            return 0.0
        }

        if option == .arc {
            if Device.current.isOneOf(Constants.iphone5Devices) {
                return CGFloat(Double.pi) / 1.75 // 2.75 - if not authorized
            } else if Device.current.isOneOf(browDevices) {
                return CGFloat(Double.pi) / 3.5 // 3.5 - if not authorized
            } else {
                return CGFloat(Double.pi) / 3.5 // 3.5 - if not authorized
            }
        }

        if option == .radius {
            if Device.current.isOneOf(Constants.iphone5Devices) {
                return 800
            } else if Device.current.isOneOf(browDevices) {
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

        labels[index]?.textColor = .commonRed
        labels[index]?.font = UIFont(name: "Roboto-Regular", size: 16)

        let indexOffset = index - previousIndex
        let direction: Direction
        switch indexOffset {
        case ..<0:
            direction = .left
        case 1...:
            direction = .right
        default:
            direction = .none
        }
        previousIndex = index

        showComponent(index: index, direction: direction)
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
                           self.gradientView.gradientLayer.colors = [self.gradients[index][0].cgColor,
                                                                     self.gradients[index][1].cgColor]

                       }, completion: nil)
    }

    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        if previousIndex < 0 || previousIndex == carousel.currentItemIndex {
            previousIndex = carousel.currentItemIndex
            labels[carousel.currentItemIndex]?.textColor = .commonRed
            labels[carousel.currentItemIndex]?.font = UIFont(name: "Roboto-Regular", size: 16)
            return
        }
        labels[previousIndex]?.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        labels[previousIndex]?.font = UIFont(name: "Roboto-Light", size: 16)

        labels[carousel.currentItemIndex]?.textColor = .commonRed
        labels[carousel.currentItemIndex]?.font = UIFont(name: "Roboto-Regular", size: 16)

        let indexOffset = carousel.currentItemIndex - previousIndex
        let direction: Direction
        switch indexOffset {
        case ..<0:
            direction = .left
        case 1...:
            direction = .right
        default:
            direction = .none
        }
        previousIndex = carousel.currentItemIndex
        showComponent(index: carousel.currentItemIndex, direction: direction)
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
                           self.gradientView.gradientLayer.colors = [self.gradients[self.previousIndex][0].cgColor,
                                                                     self.gradients[self.previousIndex][1].cgColor]
                       }, completion: nil)
    }
}

private extension CarouselViewController {

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

    func showComponent(index: Int, direction: Direction) {

        var newViewController: UIViewController?

        if let item = menuItems[index] as? ProductType {
            switch item {
            case .card:
                newViewController = storyboard?.instantiateViewController(withIdentifier: "DepositsCardsListViewController")
            case .account:
                newViewController = storyboard?.instantiateViewController(withIdentifier: "AccountsViewController")
            case .deposit:
                newViewController = storyboard?.instantiateViewController(withIdentifier: "DepositsViewController")
            case .loan:
                newViewController = storyboard?.instantiateViewController(withIdentifier: "LoansViewController")
            }
        } else if let item = menuItems[index] as? String, item == "История" {
            newViewController = storyboard?.instantiateViewController(withIdentifier: "DepositsHistoryViewController")
        }
        newViewController?.view.translatesAutoresizingMaskIntoConstraints = false

        if let currentViewController = self.currentViewController,
            let nonNilNewViewController = newViewController {
            cycleFromViewController(oldViewController: currentViewController,
                                    toViewController: nonNilNewViewController,
                                    direction: direction)
            self.currentViewController = nonNilNewViewController
        }
    }

    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController, direction: Direction) {
        oldViewController.willMove(toParent: nil)
        addChild(newViewController)
        addSubview(newViewController.view, toView: containerView)
        // TODO: Set the starting state of your constraints here
        switch direction {
        case .left:
            newViewController.view.bounds.origin.x += containerView.frame.width
        case .right:
            newViewController.view.bounds.origin.x -= containerView.frame.width
        default:
            newViewController.view.alpha = 0
            newViewController.view.bounds.origin.y -= 10
        }

        newViewController.view.layoutIfNeeded()

        // TODO: Set the ending state of your constraints here

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            switch direction {
            case .left:
                oldViewController.view.bounds.origin.x -= self.containerView.frame.width
                newViewController.view.bounds.origin.x -= self.containerView.frame.width
            case .right:
                oldViewController.view.bounds.origin.x += self.containerView.frame.width
                newViewController.view.bounds.origin.x += self.containerView.frame.width
            default:
                oldViewController.view.alpha = 0
                oldViewController.view.bounds.origin.y -= 10
            }
            // only need to call layoutIfNeeded here
            newViewController.view.layoutIfNeeded()
        }, completion: { _ in
            if direction != .left && direction != .right {
                UIView.animate(withDuration: 0.25, animations: {
                    newViewController.view.alpha = 1
                    newViewController.view.bounds.origin.y += 10

                }, completion: { _ in
                    oldViewController.view.removeFromSuperview()
                    oldViewController.removeFromParent()
                    newViewController.didMove(toParent: self)
                })
            } else {
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParent()
                newViewController.didMove(toParent: self)
            }
        })
    }

    @objc func swipeAction(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if carousel.currentItemIndex < carousel.numberOfItems - 1 {
                carousel.scrollToItem(at: carousel.currentItemIndex + 1, animated: true)
            }
        } else if gesture.direction == .right {
            if carousel.currentItemIndex > 0 {
                carousel.scrollToItem(at: carousel.currentItemIndex - 1, animated: true)
            }
        }
    }
}

extension CarouselViewController: CustomTransitionOriginator, CustomTransitionDestination {
    var fromAnimatedSubviews: [String: UIView] {
        var views = [String: UIView]()


        views["carousel"] = carousel
        guard let c = currentViewController as? CustomTransitionOriginator else {
            return views
        }
        views.merge(c.fromAnimatedSubviews, uniquingKeysWith: { (first, _) in first })
        return views
    }

    var toAnimatedSubviews: [String: UIView] {
        var views = [String: UIView]()

        views["carousel"] = carousel
        guard let c = currentViewController as? CustomTransitionDestination else {
            return views
        }
        views.merge(c.toAnimatedSubviews, uniquingKeysWith: { (first, _) in first })
        return views
    }
}

// MARK: - Public methods

extension CarouselViewController {
    @objc public func createProductButtonClicked() {
        router?.navigate(to: .createProduct)
    }
}
