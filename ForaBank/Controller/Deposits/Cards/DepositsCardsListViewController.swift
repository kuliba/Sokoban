/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import Hero

class DepositsCardsListViewController: UIViewController {
    
    //чтобы перекладывать карты
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!
    lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(dragUnselectedCardView(_:)))
        return gesture
    }()
    //чтобы выбирать карту
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCardView(_:)))
        return gesture
    }()
    //чтобы отменить выбор карты
    lazy var tapOutsidePressGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapOutsideCardView(_:)))
        return gesture
    }()
    //
    var lastCardViewCenter: CGFloat = 0
    var selectedCardView: DetailedCardView? = nil
//    var clickedCardView: DetailedCardView? = nil
    var selectedCard: Card? = nil
    
    var cardViewsTopConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    var selectedCardViewCenterYConstraint: NSLayoutConstraint? = nil
    var contentViewHeightConstraint: NSLayoutConstraint? = nil
    var sortPickerButtonTopConstraint: NSLayoutConstraint? = nil
    var allActionButtonBottomConstraint: NSLayoutConstraint? = nil
    var allActionButtonTopConstraint: NSLayoutConstraint? = nil
    var addCardButtonBottomConstraint: NSLayoutConstraint? = nil
    var addCardButtonTopConstraint: NSLayoutConstraint? = nil
    
    var cardViewHeight: CGFloat? = nil
    var cardsStackHeight: CGFloat? = nil
    let _numberOfVisibleCards = 4
    
    var cards: [Card] = [Card]() {
        didSet{
            
            activityIndicator.stopAnimating()
        }
    }
    
    var cardViews : [DetailedCardView] = [DetailedCardView]()
    
    var segueId: String? = nil
    var backSegueId: String? = nil
    
    
    
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.backgroundColor = .clear //.green
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    let contentView: UIView = {
        let cv = UIView()
        cv.backgroundColor = .clear//.red
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    let addCardButton: CardActionRoundedButton = {
        let ab = CardActionRoundedButton(type: .system)
        ab.setAttributedTitle(NSAttributedString(string: "Добавить карту", attributes: [.font:UIFont.systemFont(ofSize: 15)]), for: .normal)
        ab.tintColor = .black
        ab.translatesAutoresizingMaskIntoConstraints = false
        ab.isEnabled = false
        return ab
    }()

    let optionPickerButton: OptionPickerButton = {
        let b = OptionPickerButton(type: .system)
        b.tintColor = .black
        b.setTitle("Сортировать по состоянию счета", for: .normal)
        b.contentHorizontalAlignment = .left
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let allActionButton: CardActionRoundedButton = {
        let b = CardActionRoundedButton(type: .system)
        b.setAttributedTitle(NSAttributedString(string: "Все действия", attributes: [.font:UIFont.systemFont(ofSize: 15)]), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        b.addTarget(self, action: #selector(allActionButtonClicked(_:)), for: .touchUpInside)
        return b
    }()
    
    let sendMoneyButton: CardActionRoundedButton = {
        let b = CardActionRoundedButton(type: .system)
        b.tintColor = .black
        b.setImage(UIImage(named: "deposit_cards_list_onhold_sendmoney_button"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()
    
    let addMoneyButton: CardActionRoundedButton = {
        let b = CardActionRoundedButton(type: .system)
        b.tintColor = .black
        b.setImage(UIImage(named: "deposit_cards_list_onhold_addmoney_button"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()
    
    let blockCardButton: CardActionRoundedButton = {
        let b = CardActionRoundedButton()
        b.layer.borderColor = UIColor(hexFromString: "EC433D")!.cgColor
        b.tintColor = .red
        
        let templateImage = UIImage(named: "deposits_cards_details_management_block_icon")?
            .withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        b.setImage(templateImage, for: .normal)
        b.setImage(UIImage(named: "deposit_cards_list_onhold_block_button_highlighted"), for: .highlighted)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()

    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addScrollView()
        addButtons()
//        print("DepositsCardsListViewController viewDidLoad")
        hero.isEnabled = true
        hero.modalAnimationType = .none
        saveData()
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if contentViewHeightConstraint == nil {
            contentViewHeightConstraint = NSLayoutConstraint(item: contentView,
                                                             attribute: .height,
                                                             relatedBy: .equal,
                                                             toItem: scrollView,
                                                             attribute: .height,
                                                             multiplier: 1,
                                                             constant: 0)
            scrollView.addConstraint(contentViewHeightConstraint!)
        }
        if segueId == "CardDetailsViewController" {
            view.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(4)
                    ]),
                HeroModifier.duration(0.25),
//                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot
            ]
            if let selectedCardView = selectedCardView,
                let zIndex = cardViews.firstIndex(of: selectedCardView) {
                var i = zIndex+1 >= cardViews.count ? 0 : zIndex + 1
                while i != zIndex {
                    cardViews[i].hero.id = "\(i)"
                    cardViews[i].hero.modifiers = [
                        HeroModifier.beginWith(modifiers: [
                            HeroModifier.opacity(1),
                            HeroModifier.zPosition(CGFloat(11 + (i - zIndex)))
                            ]),
                        HeroModifier.duration(0.5),
                        HeroModifier.opacity(0),
                        HeroModifier.zPosition(CGFloat(11 + (i - zIndex))),
                        HeroModifier.useGlobalCoordinateSpace,
                        HeroModifier.translate(CGPoint(x: 0, y: view.frame.height)),
                    ]
                    if i+1 >= cardViews.count {
                        i = 0
                    } else {
                        i += 1
                    }
                }
            }
            selectedCardView?.hero.id = "card"
            selectedCardView?.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(1),
                HeroModifier.zPosition(11),
                //                HeroModifier.useNormalSnapshot
            ]
            selectedCardView?.backgroundImageView.hero.id = "backgroundImageView"
            //            selectedCardView?.backgroundImageView.hero.id = "card"
            selectedCardView?.backgroundImageView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.zPosition(11),
                HeroModifier.useNormalSnapshot
            ]
            selectedCardView?.logoImageView.hero.id = "logoImageView"
            selectedCardView?.logoImageView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot,
                HeroModifier.zPosition(11)
            ]
            selectedCardView?.paypassLogoImageView.hero.id = "paypassLogoImageView"
            selectedCardView?.paypassLogoImageView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot,
                HeroModifier.zPosition(11)
            ]
            selectedCardView?.titleLabel.hero.id = "titleLabel"
            selectedCardView?.titleLabel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot,
                HeroModifier.zPosition(11)
            ]
            selectedCardView?.cardNumberLabel.hero.id = "cardNumberLabel"
            selectedCardView?.cardNumberLabel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.zPosition(11),
                HeroModifier.useNormalSnapshot
            ]
            selectedCardView?.cardValidityPeriodLabel.hero.id = "cardValidityPeriodLabel"
            selectedCardView?.cardValidityPeriodLabel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot,
                HeroModifier.zPosition(11)
            ]
            selectedCardView?.cardCashLabel.hero.id = "cardCashLabel"
            selectedCardView?.cardCashLabel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.zPosition(11),
                HeroModifier.useNormalSnapshot
            ]
            
            selectedCardView?.cardBlockedImageView.hero.id = "cardBlockedImageView"
            selectedCardView?.cardBlockedImageView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot,
                HeroModifier.zPosition(11)
            ]
        }
        
        if (cards == nil) {
            activityIndicator.startAnimation()
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height)
        cardViews.forEach { (d) in
            d.hero.id = nil
            d.hero.modifiers = nil
        }
        selectedCardView?.hero.id = nil
        selectedCardView?.hero.modifiers = nil
        view.hero.modifiers = nil
        selectedCardView?.backgroundImageView.hero.id = nil
        selectedCardView?.backgroundImageView.hero.modifiers = nil
        selectedCardView?.logoImageView.hero.id = nil
        selectedCardView?.logoImageView.hero.modifiers = nil
        selectedCardView?.paypassLogoImageView.hero.id = nil
        selectedCardView?.paypassLogoImageView.hero.modifiers = nil
        selectedCardView?.titleLabel.hero.id = nil
        selectedCardView?.titleLabel.hero.modifiers = nil
        selectedCardView?.cardNumberLabel.hero.id = nil
        selectedCardView?.cardNumberLabel.hero.modifiers = nil
        selectedCardView?.cardValidityPeriodLabel.hero.id = nil
        selectedCardView?.cardValidityPeriodLabel.hero.modifiers = nil
        selectedCardView?.cardCashLabel.hero.id = nil
        selectedCardView?.cardCashLabel.hero.modifiers = nil
        selectedCardView?.cardBlockedImageView.hero.id = nil
        selectedCardView?.cardBlockedImageView.hero.modifiers = nil
        
        if cards.count > 0 {
            updateCardViews()
            return
        }
        NetworkManager.shared().getCardList { [weak self] (success, cards) in
            if success {
                self?.cards = cards ?? []
                if self?.cardViews.count == 0 {
                    //                    self.removeCardViews()
                    self?.addCardViews()
                } else {
                    self?.updateCardViews()
                    if self?.selectedCard?.blocked == true {
                        self?.sendMoneyButton.isEnabled = false
                        self?.addMoneyButton.isEnabled = false
                        self?.blockCardButton.isEnabled = false
                    } else {
                        self?.sendMoneyButton.isEnabled = true
                        self?.addMoneyButton.isEnabled = true
                        self?.blockCardButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if segueId == "CardDetailsViewController" {
            view.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(4)
                    ]),
                HeroModifier.duration(0.25),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot
            ]
            if let selectedCardView = selectedCardView,
                let zIndex = cardViews.firstIndex(of: selectedCardView) {
                var i = zIndex+1 >= cardViews.count ? 0 : zIndex + 1
                while i != zIndex {
                    cardViews[i].hero.id = "\(i)"
                    cardViews[i].hero.modifiers = [
                        HeroModifier.beginWith(modifiers: [
                            HeroModifier.opacity(1),
                            HeroModifier.zPosition(CGFloat(11 + (i - zIndex)))
                            ]),
                        HeroModifier.duration(0.5),
                        HeroModifier.opacity(0),
                        HeroModifier.zPosition(CGFloat(11 + (i - zIndex))),
                        HeroModifier.useGlobalCoordinateSpace,
                        HeroModifier.translate(CGPoint(x: 0, y: view.frame.height)),
                    ]
                    if i+1 >= cardViews.count {
                        i = 0
                    } else {
                        i += 1
                    }
                }
            }
            selectedCardView?.hero.id = "card"
            selectedCardView?.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(11)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(1),
                HeroModifier.zPosition(11),
//                HeroModifier.useNormalSnapshot
            ]
            selectedCardView?.backgroundImageView.hero.id = "backgroundImageView"
//            selectedCardView?.backgroundImageView.hero.id = "card"
            selectedCardView?.backgroundImageView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(8)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.zPosition(8)
            ]
            selectedCardView?.logoImageView.hero.id = "logoImageView"
            selectedCardView?.logoImageView.hero.modifiers = [
                    HeroModifier.beginWith([
                        HeroModifier.opacity(1),
                        HeroModifier.zPosition(8)
                        ]),
                    HeroModifier.duration(0.5),
                    HeroModifier.opacity(0),
                    HeroModifier.useNormalSnapshot
            ]
            selectedCardView?.paypassLogoImageView.hero.id = "paypassLogoImageView"
            selectedCardView?.paypassLogoImageView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(8)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot
            ]
            selectedCardView?.titleLabel.hero.id = "titleLabel"
            selectedCardView?.titleLabel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(8)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot
            ]
            selectedCardView?.cardNumberLabel.hero.id = "cardNumberLabel"
            selectedCardView?.cardNumberLabel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(8)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.zPosition(8),
                HeroModifier.useNormalSnapshot
            ]
            selectedCardView?.cardValidityPeriodLabel.hero.id = "cardValidityPeriodLabel"
            selectedCardView?.cardValidityPeriodLabel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(8)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot
            ]
            selectedCardView?.cardCashLabel.hero.id = "cardCashLabel"
            selectedCardView?.cardCashLabel.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(8)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot,
                HeroModifier.zPosition(8)
            ]
            
            selectedCardView?.cardBlockedImageView.hero.id = "cardBlockedImageView"
            selectedCardView?.cardBlockedImageView.hero.modifiers = [
                HeroModifier.beginWith([
                    HeroModifier.opacity(1),
                    HeroModifier.zPosition(8)
                    ]),
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0),
                HeroModifier.useNormalSnapshot
            ]
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectedCardView?.hero.id = nil
        selectedCardView?.hero.modifiers = nil
        view.hero.modifiers = nil
        selectedCardView?.backgroundImageView.hero.id = nil
        selectedCardView?.backgroundImageView.hero.modifiers = nil
        selectedCardView?.logoImageView.hero.id = nil
        selectedCardView?.logoImageView.hero.modifiers = nil
        selectedCardView?.paypassLogoImageView.hero.id = nil
        selectedCardView?.paypassLogoImageView.hero.modifiers = nil
        selectedCardView?.titleLabel.hero.id = nil
        selectedCardView?.titleLabel.hero.modifiers = nil
        selectedCardView?.cardNumberLabel.hero.id = nil
        selectedCardView?.cardNumberLabel.hero.modifiers = nil
        selectedCardView?.cardValidityPeriodLabel.hero.id = nil
        selectedCardView?.cardValidityPeriodLabel.hero.modifiers = nil
        selectedCardView?.cardCashLabel.hero.id = nil
        selectedCardView?.cardCashLabel.hero.modifiers = nil
        selectedCardView?.cardBlockedImageView.hero.id = nil
        selectedCardView?.cardBlockedImageView.hero.modifiers = nil
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if let c = cardViews.last {
//            lastCardViewCenter = c.center
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueId = nil
        if segue.identifier == "DepositsCardListOnholdBlock" {
            if let destinationVC = segue.destination as? DepositsCardsListOnholdBlockViewController {
                destinationVC.card = self.cards.last
            }
        } else if let vc = segue.destination as? CardDetailsViewController,
            let parent = parent as? CarouselViewController {
            vc.card = selectedCard
            segueId = segue.identifier
            vc.segueId = segueId
            vc.backSegueId = segueId
            parent.segueId = segueId
            parent.backSegueId = segueId
        }
    }
    

    // MARK: - Actions
    @objc func allActionButtonClicked(_ sender: UIButton!) {
        selectedCard = selectedCardView?.card
        performSegue(withIdentifier: "CardDetailsViewController", sender: nil)
    }
    
    @objc func cardViewClicked(_ sender: UITapGestureRecognizer) {
        if let cardView = sender.view as? DetailedCardView {
            selectedCard = cardView.card
            selectedCardView = cardView
            performSegue(withIdentifier: "CardDetailsViewController", sender: nil)
        }
    }
    
    @objc func tapOutsideCardView(_ sender:UITapGestureRecognizer){
        animateCardViewsToDefaultState()
    }
    
    @objc func longPressCardView(_ sender:UILongPressGestureRecognizer){
        if sender.state == .began {
            focusOnCard()
        }
        
//        UIView.transition(with: contentView, duration: 0.5, options: .transitionCrossDissolve, animations: {
//            self.addCardButton.isHidden = true
//            self.allActionButton.isHidden = false
//            self.contentViewHeightConstraint?.constant = self.scrollView.frame.height
//        })
    }
    
    @objc func dragUnselectedCardView(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: contentView)
        let newCenterY = sender.view!.center.y + translation.y
        let newBottomY = newCenterY + sender.view!.frame.size.height/2
        let newTopY = newCenterY - sender.view!.frame.size.height/2
        let setY = (newBottomY < addCardButton.frame.origin.y && newTopY > optionPickerButton.frame.origin.y+optionPickerButton.frame.size.height) ? newCenterY : sender.view!.center.y
        sender.view!.center = CGPoint(x: sender.view!.center.x, y: setY)
        sender.setTranslation(CGPoint.zero, in: self.view)
//        sender.view!.alpha = (newTopY - optionPickerButton.frame.origin.y+optionPickerButton.frame.size.height) / (self.lastCardViewCenter.y - sender.view!.frame.height/2)
        if sender.state == .ended {
            if let cardView = sender.view as? DetailedCardView,
                cardView.center.y - optionPickerButton.frame.origin.y - optionPickerButton.frame.size.height > lastCardViewCenter {
                focusOnCard()
//                UIView.animate(withDuration: 0.25,
//                               delay: 0,
//                               options: .curveEaseIn,
//                               animations: {
//                                sender.view!.center = self.lastCardViewCenter
//                                //self.contentView.layoutIfNeeded()
//
//                },
//                               completion: { (_) in
//                                sender.view?.alpha = 1
//                })
            } else {
                sendFrontCardViewToBack()
            }
        }
    }
    
    @objc func dragSelectedCardView(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: contentView)
        let newCenterY = sender.view!.center.y + translation.y
        let newBottomY = newCenterY + sender.view!.frame.size.height/2
        let newTopY = newCenterY - sender.view!.frame.size.height/2
        let setY = (newBottomY < addCardButton.frame.origin.y && newTopY > optionPickerButton.frame.origin.y+optionPickerButton.frame.size.height) ? newCenterY : sender.view!.center.y
        sender.view?.center = CGPoint(x: sender.view!.center.x, y: setY)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        if sender.state == .ended {
            animateCardViewsToDefaultState()
        }
    }
    
    @objc func blockCardButtonClicked(_ sender: UIButton!) {
        performSegue(withIdentifier: "DepositsCardListOnholdBlock", sender: nil)
    }
    
    @objc func optionPickerButtonClicked(_ sender: UIButton!) {
        
        if let vc = UIStoryboard(name: "Payment", bundle: nil)
            .instantiateViewController(withIdentifier: "ppvc") as? OptionPickerViewController {
            
            // Pass picker frame to determine picker popup coordinates
            vc.pickerFrame = contentView.convert(optionPickerButton.frame, to: nil)
            vc.pickerFrame.origin.x = vc.pickerFrame.origin.x + 25
            vc.pickerFrame.size.width = vc.pickerFrame.size.width - 25
            vc.pickerOptions = ["по состоянию счета", "по сроку годности", "по имени"]
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
}

extension DepositsCardsListViewController: OptionPickerDelegate {
    func setSelectedOption(option: String?) {
        if let option = option {
            optionPickerButton.setTitle("Сортировать \(option)", for: [])
        }
    }
}

private extension DepositsCardsListViewController {
    func addScrollView() {
        //UIScrollView
        self.view.addSubview(scrollView)
        // constraints the scroll view
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView":scrollView])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView":scrollView])
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        
        //contentView
        scrollView.addSubview(contentView)
        scrollView.addConstraint(NSLayoutConstraint(item: contentView,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: scrollView,
                                                    attribute: .width,
                                                    multiplier: 1,
                                                    constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: contentView,
                                                    attribute: .left,
                                                    relatedBy: .equal,
                                                    toItem: scrollView,
                                                    attribute: .left,
                                                    multiplier: 1,
                                                    constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: contentView,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: scrollView,
                                                    attribute: .top,
                                                    multiplier: 1,
                                                    constant: 0))
    }
    func addButtons() {
        //pickerButton
        optionPickerButton.addTarget(self, action: #selector(optionPickerButtonClicked(_:)), for: .touchUpInside)
        contentView.addSubview(optionPickerButton)
        
        //addCardButton
        contentView.addSubview(addCardButton)
        // constraints addCardButton
        var horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[addCardButton]-20-|", options: [], metrics: nil, views: ["addCardButton":addCardButton])
        contentView.addConstraints(horizontalConstraints)
        addCardButtonBottomConstraint = NSLayoutConstraint(item: addCardButton,
                                                           attribute: .bottom,
                                                           relatedBy: .equal,
                                                           toItem: contentView,
                                                           attribute: .bottom,
                                                           multiplier: 1,
                                                           constant: -20)
        contentView.addConstraint(addCardButtonBottomConstraint!)
        contentView.addConstraint(NSLayoutConstraint(item: addCardButton,
                                                     attribute: .height,
                                                     relatedBy: .equal,
                                                     toItem: nil,
                                                     attribute: .notAnAttribute,
                                                     multiplier: 1,
                                                     constant: 45))
        //allActionButton
        contentView.addSubview(allActionButton)
        // constraints allActionButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[allActionButton]-20-|", options: [], metrics: nil, views: ["allActionButton":allActionButton])
        contentView.addConstraints(horizontalConstraints)
        allActionButtonBottomConstraint = NSLayoutConstraint(item: allActionButton,
                                                             attribute: .bottom,
                                                             relatedBy: .equal,
                                                             toItem: contentView,
                                                             attribute: .bottom,
                                                             multiplier: 1,
                                                             constant: 20)
        contentView.addConstraint(allActionButtonBottomConstraint!)
        contentView.addConstraint(NSLayoutConstraint(item: allActionButton,
                                                     attribute: .height,
                                                     relatedBy: .equal,
                                                     toItem: nil,
                                                     attribute: .notAnAttribute,
                                                     multiplier: 1,
                                                     constant: 45))
        
        //sendMoneyButton
        contentView.addSubview(sendMoneyButton)
        // constraints sendMoneyButton
        contentView.addConstraint(NSLayoutConstraint(item: sendMoneyButton,
                                                     attribute: .centerX,
                                                     relatedBy: .equal,
                                                     toItem: contentView,
                                                     attribute: .centerX,
                                                     multiplier: 1,
                                                     constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: sendMoneyButton,
                                                     attribute: .width,
                                                     relatedBy: .equal,
                                                     toItem: nil,
                                                     attribute: .notAnAttribute,
                                                     multiplier: 1,
                                                     constant: 45))
        var verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[sendMoneyButton(45)]-15-[allActionButton]", options: [], metrics: nil, views: ["sendMoneyButton":sendMoneyButton, "allActionButton":allActionButton])
        contentView.addConstraints(verticalConstraints)
        
        //addMoneyButton
        contentView.addSubview(addMoneyButton)
        // constraints addMoneyButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[addMoneyButton(45)]-20-[sendMoneyButton]", options: [], metrics: nil, views: ["addMoneyButton":addMoneyButton,"sendMoneyButton":sendMoneyButton])
        contentView.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[addMoneyButton(45)]-15-[allActionButton]", options: [], metrics: nil, views: ["addMoneyButton":addMoneyButton, "allActionButton":allActionButton])
        contentView.addConstraints(verticalConstraints)
        
        //blockCardButton
        blockCardButton.addTarget(self, action: #selector(blockCardButtonClicked(_:)), for: .touchUpInside)
        contentView.addSubview(blockCardButton)
        // constraints blockCardButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[sendMoneyButton]-20-[blockCardButton(45)]", options: [], metrics: nil, views: ["blockCardButton":blockCardButton,"sendMoneyButton":sendMoneyButton])
        contentView.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[blockCardButton(45)]-15-[allActionButton]", options: [], metrics: nil, views: ["blockCardButton":blockCardButton, "allActionButton":allActionButton])
        contentView.addConstraints(verticalConstraints)
        
        // constraints sortPickerButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[sortPickerButton]-20-|", options: [], metrics: nil, views: ["sortPickerButton":optionPickerButton])
        contentView.addConstraints(horizontalConstraints)
        sortPickerButtonTopConstraint = NSLayoutConstraint(item: optionPickerButton,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: contentView,
                                                           attribute: .top,
                                                           multiplier: 1,
                                                           constant: 40)
        contentView.addConstraint(sortPickerButtonTopConstraint!)
        contentView.addConstraint(NSLayoutConstraint(item: optionPickerButton,
                                                     attribute: .height,
                                                     relatedBy: .equal,
                                                     toItem: nil,
                                                     attribute: .notAnAttribute,
                                                     multiplier: 1,
                                                     constant: 35))
    }
    
    func addCardViews() {
        if cards.count == 0 {
            return
        }
        
        let cardWidth = UIScreen.main.bounds.width - 40
        cardViewHeight = CGFloat(cardWidth)*160/280

        let visibleCardsCount = cards.count > _numberOfVisibleCards ? _numberOfVisibleCards : cards.count //4 карты видно хорошо, остальные едва заметны
        let unvisibleCardsCount = cards.count > _numberOfVisibleCards ? cards.count-_numberOfVisibleCards : 0
        
        cardsStackHeight = CGFloat(visibleCardsCount)*(cardViewHeight!) + (CGFloat(visibleCardsCount)-1)*(50-cardViewHeight!) + CGFloat(unvisibleCardsCount>0 ? 5 : 0)
        lastCardViewCenter = cardsStackHeight! - cardViewHeight!/2 + 20//20 - vertical space between first cardView and optionPickerButton
        
        if contentViewHeightConstraint != nil {
            scrollView.removeConstraint(contentViewHeightConstraint!)
        }
        contentViewHeightConstraint = NSLayoutConstraint(item: contentView,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .notAnAttribute,
                                                         multiplier: 1,
                                                         constant: cardsStackHeight!+180)
        scrollView.addConstraint(contentViewHeightConstraint!)
        
        //CardViews
        cardViews = []
        
        for (i, c) in cards.enumerated() {
            let cardView = DetailedCardView(withCard: c)
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.2
            cardView.layer.shadowOffset = CGSize(width: 1, height: -1)
            cardView.layer.shadowRadius = 4
            //            cardView.layer.shouldRasterize = true
            cardView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(cardView)
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[cardView]-20-|", options: [], metrics: nil, views: ["cardView":cardView])
            contentView.addConstraints(horizontalConstraints)
            var topInset: CGFloat = 20
            if i >= unvisibleCardsCount {
                topInset = 20+CGFloat(i-unvisibleCardsCount)*50.0 + CGFloat(unvisibleCardsCount>0 ? 5 : 0)
            }
            //20+CGFloat(i)*50.0
            let cardViewTopConstraint = NSLayoutConstraint(item: cardView,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: optionPickerButton,
                                                           attribute: .bottom,
                                                           multiplier: 1,
                                                           constant: topInset)
            cardViewsTopConstraints.append(cardViewTopConstraint)
            contentView.addConstraint(cardViewTopConstraint)
            contentView.addConstraint(NSLayoutConstraint(item: cardView,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .height,
                                                         multiplier: 1,
                                                         constant: cardViewHeight!))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardViewClicked(_:)))
            cardView.addGestureRecognizer(tapGesture)
            cardViews.append(cardView)
        }
        //        panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragUnselectedCardView(_:)))
        selectedCardView = cardViews.last
        selectedCard = cards.last
        selectedCardView!.isUserInteractionEnabled = true
        selectedCardView!.addGestureRecognizer(panGesture)
        //        contentViewConstraints = contentView.constraints
        //        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCardView(_:)))
        
        selectedCardView!.addGestureRecognizer(longPressGesture)
    }
    
//    func removeCardViews() {
//        for v in cardViews {
//            v.removeFromSuperview()
//        }
//    }
    func saveData() {
        UserDefaults.standard.set(cards, forKey:  "item")
        UserDefaults.standard.synchronize()
    }
    
    func updateCardViews() {
        for (i, v) in cardViews.enumerated() {
            v.update(withCard: cards[i])
        }
        selectedCardView = cardViews.last
        selectedCard = selectedCardView?.card
    }
    
    func focusOnCard() {
        self.selectedCardView?.removeGestureRecognizer(self.longPressGesture)
        self.scrollView.addGestureRecognizer(tapOutsidePressGesture)
        sendMoneyButton.alpha = 0
        blockCardButton.alpha = 0
        addMoneyButton.alpha = 0
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .layoutSubviews,
                       animations: {
                        if self.selectedCard?.blocked == true {
                            self.sendMoneyButton.isEnabled = false
                            self.addMoneyButton.isEnabled = false
                            self.blockCardButton.isEnabled = false
                        } else {
                            self.sendMoneyButton.isEnabled = true
                            self.addMoneyButton.isEnabled = true
                            self.blockCardButton.isEnabled = true
                        }
                        self.addCardButton.isHidden = true
                        self.optionPickerButton.isHidden = true
                        self.sendMoneyButton.isHidden = false
                        self.addMoneyButton.isHidden = false
                        self.blockCardButton.isHidden = false
                        self.allActionButton.isHidden = false
                        self.sendMoneyButton.alpha = 1
                        self.blockCardButton.alpha = 1
                        self.addMoneyButton.alpha = 1
                        self.contentViewHeightConstraint?.constant = self.scrollView.frame.height
                        self.sortPickerButtonTopConstraint?.constant = -40
                        self.contentView.removeConstraint(self.cardViewsTopConstraints.last!)
                        self.selectedCardViewCenterYConstraint = NSLayoutConstraint(item: self.selectedCardView!,
                                                                                    attribute: .centerY,
                                                                                    relatedBy: .equal,
                                                                                    toItem: self.contentView,
                                                                                    attribute: .centerY,
                                                                                    multiplier: 1,
                                                                                    constant: 0)
                        self.contentView.addConstraint(self.selectedCardViewCenterYConstraint!)
                        for i in 0..<self.cardViewsTopConstraints.count {
                            if i != self.cardViewsTopConstraints.count-1 {
                                self.cardViewsTopConstraints[i].constant = CGFloat(40-(5*i))-self.cardViewHeight!
                            }
                        }
                        self.contentView.removeConstraint(self.allActionButtonBottomConstraint!)
                        self.allActionButtonTopConstraint = NSLayoutConstraint(item: self.allActionButton,
                                                                               attribute: .top,
                                                                               relatedBy: .equal,
                                                                               toItem: self.selectedCardView,
                                                                               attribute: .bottom,
                                                                               multiplier: 1,
                                                                               constant: 80)
                        self.contentView.addConstraint(self.allActionButtonTopConstraint!)
                        self.contentView.removeConstraint(self.addCardButtonBottomConstraint!)
                        self.addCardButtonTopConstraint = NSLayoutConstraint(item: self.addCardButton,
                                                                             attribute: .top,
                                                                             relatedBy: .equal,
                                                                             toItem: self.selectedCardView,
                                                                             attribute: .bottom,
                                                                             multiplier: 1,
                                                                             constant: 80)
                        self.contentView.addConstraint(self.addCardButtonTopConstraint!)
                        self.scrollView.layoutIfNeeded()
        },
                       completion: { (f: Bool) in
                        self.panGesture.removeTarget(self, action: #selector(self.dragUnselectedCardView(_:)))
                        self.panGesture.addTarget(self, action: #selector(self.dragSelectedCardView(_:)))
                        
        })
    }
    
    func sendFrontCardViewToBack() {
        let tempCard = cards.last
        let tempCardView = cardViews.last
        let tempCardViewConstraint = cardViewsTopConstraints.last
        
        cards.removeLast(1)
        cards.insert(tempCard!, at: 0)
        cardViews.removeLast(1)
        cardViews.insert(tempCardView!, at: 0)
        cardViewsTopConstraints.removeLast(1)
        cardViewsTopConstraints.insert(tempCardViewConstraint!, at: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        //                        let visibleCardsCount = self.cards.count > self._numberOfVisibleCards ? self._numberOfVisibleCards : self.cards.count //4 карты видно хорошо, остальные едва заметны
                        let unvisibleCardsCount = self.cards.count > self._numberOfVisibleCards ? self.cards.count-self._numberOfVisibleCards : 0
                        for i in 0..<self.cardViewsTopConstraints.count {
                            if i < unvisibleCardsCount {
                                self.cardViewsTopConstraints[i].constant = 20
                                //                                self.cardViewsTopConstraints[i].constant -= 50*CGFloat(visibleCardsCount-1) - CGFloat(unvisibleCardsCount>0 ? 5 : 0)
                                //25+CGFloat(i-unvisibleCardsCount-1)*50.0
                            } else {
                                self.cardViewsTopConstraints[i].constant = 25+CGFloat(i-unvisibleCardsCount)*50.0
                                //25+CGFloat(i-unvisibleCardsCount-1)*50.0
                            }
                        }
                        self.contentView.layoutIfNeeded()
        },
                       completion:  { (f: Bool) in
                        self.selectedCardView?.alpha = 1
                        self.contentView.sendSubviewToBack(self.selectedCardView!)
                        self.selectedCardView?.removeGestureRecognizer(self.panGesture)
                        self.selectedCardView?.removeGestureRecognizer(self.longPressGesture)
                        self.selectedCardView = self.cardViews.last
                        self.selectedCard = self.cards.last
                        self.selectedCardView?.addGestureRecognizer(self.panGesture)
                        self.selectedCardView?.addGestureRecognizer(self.longPressGesture)
        })
    }
    
    func animateCardViewsToDefaultState() {
        addCardButton.alpha = 0
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        self.addCardButton.isHidden = false
                        self.optionPickerButton.isHidden = false
                        self.sendMoneyButton.isHidden = true
                        self.addMoneyButton.isHidden = true
                        self.blockCardButton.isHidden = true
                        self.allActionButton.isHidden = true
                        self.sendMoneyButton.alpha = 0
                        self.blockCardButton.alpha = 0
                        self.addMoneyButton.alpha = 0
                        self.addCardButton.alpha = 1
                        self.contentViewHeightConstraint?.constant = self.cardsStackHeight!+180
                        self.sortPickerButtonTopConstraint?.constant = 40
                        self.contentView.removeConstraint(self.selectedCardViewCenterYConstraint!)
                        
                        self.contentView.addConstraint(self.cardViewsTopConstraints.last!)
                        //                        let visibleCardsCount = self.cards.count > self._numberOfVisibleCards ? self._numberOfVisibleCards : self.cards.count //4 карты видно хорошо, остальные едва заметны
                        let unvisibleCardsCount = self.cards.count > self._numberOfVisibleCards ? self.cards.count-self._numberOfVisibleCards : 0
                        for i in 0..<self.cardViewsTopConstraints.count {
                            if i != self.cardViewsTopConstraints.count-1 {
                                var topInset: CGFloat = 20
                                if i >= unvisibleCardsCount {
                                    topInset = 25+CGFloat(i-unvisibleCardsCount)*50.0
                                }
                                self.cardViewsTopConstraints[i].constant = topInset//20+CGFloat(i)*50.0
                            }
                        }
                        self.contentView.removeConstraint(self.allActionButtonTopConstraint!)
                        self.contentView.addConstraint(self.allActionButtonBottomConstraint!)
                        self.contentView.removeConstraint(self.addCardButtonTopConstraint!)
                        self.contentView.addConstraint(self.addCardButtonBottomConstraint!)
                        self.scrollView.layoutIfNeeded()
                        
        },
                       completion: {(f:Bool) in
                        self.selectedCardView?.addGestureRecognizer(self.longPressGesture)
                        self.scrollView.removeGestureRecognizer(self.tapOutsidePressGesture)
                        self.panGesture.removeTarget(self, action: #selector(self.dragSelectedCardView(_:)))
                        self.panGesture.addTarget(self, action: #selector(self.dragUnselectedCardView(_:)))
        })
    }
}
