//
//  DepositsCardsListViewController.swift
//  ForaBank
//
//  Created by Sergey on 16/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsCardsListViewController: UIViewController {
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(dragUnselectedCardView(_:)))
        return gesture
    }()
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCardView(_:)))
        return gesture
    }()
    var lastCardViewCenter: CGPoint = CGPoint.zero
    var selectedCardView: DetailedCardView? = nil
    
    var cardViewsTopConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    var selectedCardViewCenterYConstraint: NSLayoutConstraint? = nil
    var contentViewHeightConstraint: NSLayoutConstraint? = nil
    var sortPickerButtonTopConstraint: NSLayoutConstraint? = nil
    var allActionButtonBottomConstraint: NSLayoutConstraint? = nil
    var allActionButtonTopConstraint: NSLayoutConstraint? = nil
    var addCardButtonBottomConstraint: NSLayoutConstraint? = nil
    var addCardButtonTopConstraint: NSLayoutConstraint? = nil
    var contentViewConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    
    var cardViewHeight: CGFloat? = nil
    var cardsStackHeight: CGFloat? = nil
    
    var cards: [Card] = [Card]()
    var cardViews : [DetailedCardView] = [DetailedCardView]()
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
        b.layer.borderColor = UIColor(hexFromString: "EC433D").cgColor
        b.setImage(UIImage(named: "deposit_cards_list_onhold_block_button"), for: .normal)
        b.setImage(UIImage(named: "deposit_cards_list_onhold_block_button_highlighted"), for: .highlighted)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        //let screenSize: CGRect = UIScreen.main.bounds
        //UIScrollView
        self.view.addSubview(scrollView)
        // constrain the scroll view
        var horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView":scrollView])
        var verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView":scrollView])
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        
        //contentView
//        contentView.con
        scrollView.addSubview(contentView)
        scrollView.addConstraint(NSLayoutConstraint(item: contentView,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: 0))
       
        
        //pickerButton
        optionPickerButton.addTarget(self, action: #selector(optionPickerButtonClicked(_:)), for: .touchUpInside)
        contentView.addSubview(optionPickerButton)
        //reasonPickerButton.addTarget(self, action: #selector(reasonPickerButtonClicked(_:)), for: .touchUpInside)
        
        //addCardButton
        contentView.addSubview(addCardButton)
        // constrain addCardButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[addCardButton]-20-|", options: [], metrics: nil, views: ["addCardButton":addCardButton])
//        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[addCardButton(45)]-20-|", options: [], metrics: nil, views: ["addCardButton":addCardButton])
        contentView.addConstraints(horizontalConstraints)
//        contentView.addConstraints(verticalConstraints)
        addCardButtonBottomConstraint = NSLayoutConstraint(item: addCardButton,
                                                             attribute: .bottom,
                                                             relatedBy: .equal,
                                                             toItem: contentView,
                                                             attribute: .bottom,
                                                             multiplier: 1,
                                                             constant: 20)
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
        // constrain allActionButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[allActionButton]-20-|", options: [], metrics: nil, views: ["allActionButton":allActionButton])
//        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[allActionButton(45)]-20-|", options: [], metrics: nil, views: ["allActionButton":allActionButton])
        contentView.addConstraints(horizontalConstraints)
//        contentView.addConstraints(verticalConstraints)
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
        // constrain sendMoneyButton
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
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[sendMoneyButton(45)]-15-[allActionButton]", options: [], metrics: nil, views: ["sendMoneyButton":sendMoneyButton, "allActionButton":allActionButton])
        contentView.addConstraints(verticalConstraints)

        //addMoneyButton
        contentView.addSubview(addMoneyButton)
        // constrain addMoneyButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[addMoneyButton(45)]-20-[sendMoneyButton]", options: [], metrics: nil, views: ["addMoneyButton":addMoneyButton,"sendMoneyButton":sendMoneyButton])
        contentView.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[addMoneyButton(45)]-15-[allActionButton]", options: [], metrics: nil, views: ["addMoneyButton":addMoneyButton, "allActionButton":allActionButton])
        contentView.addConstraints(verticalConstraints)

        //blockCardButton
        blockCardButton.addTarget(self, action: #selector(blockCardButtonClicked(_:)), for: .touchUpInside)
        contentView.addSubview(blockCardButton)
        // constrain blockCardButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[sendMoneyButton]-20-[blockCardButton(45)]", options: [], metrics: nil, views: ["blockCardButton":blockCardButton,"sendMoneyButton":sendMoneyButton])
        contentView.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[blockCardButton(45)]-15-[allActionButton]", options: [], metrics: nil, views: ["blockCardButton":blockCardButton, "allActionButton":allActionButton])
        contentView.addConstraints(verticalConstraints)
        
        // constrain sortPickerButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[sortPickerButton]-20-|", options: [], metrics: nil, views: ["sortPickerButton":optionPickerButton])
//        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[sortPickerButton(35)]", options: [], metrics: nil, views: ["sortPickerButton":sortPickerButton])
        contentView.addConstraints(horizontalConstraints)
//        contentView.addConstraints(verticalConstraints)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if cardViews.count != 0 {
            if CardManager.shared().hasBlockedCard {
                selectedCardView?.blockCard()
                animateCardViewsToDefaultState()
            }
            return
        }
        
        if CardManager.shared().hasBlockedCard {
            cards = CardManager.shared().cards.reversed()
        } else {
            cards = CardManager.shared().cards
        }
        let cardWidth = UIScreen.main.bounds.width - 40
        cardViewHeight = CGFloat(cardWidth)*160/280
        let cardsCount = CGFloat(cards.count)
//        cardsStackView.spacing = 40-cardHeight
        cardsStackHeight = cardsCount*(cardViewHeight!)+(cardsCount-1)*(50-cardViewHeight!)

        contentViewHeightConstraint = NSLayoutConstraint(item: contentView,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .notAnAttribute,
                                                         multiplier: 1,
                                                         constant: cardsStackHeight!+180)
        scrollView.addConstraint(contentViewHeightConstraint!)

        //CardViews
        for (i, c) in cards.enumerated() {
            let cardView = DetailedCardView(withCard: c)
            
            cardView.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(cardView)
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[cardView]-20-|", options: [], metrics: nil, views: ["cardView":cardView])
            contentView.addConstraints(horizontalConstraints)
            let cardViewTopConstraint = NSLayoutConstraint(item: cardView,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: optionPickerButton,
                                                           attribute: .bottom,
                                                           multiplier: 1,
                                                           constant: 20+CGFloat(i)*50.0)
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
            print(tapGesture)
            cardViews.append(cardView)
        }
//        panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragUnselectedCardView(_:)))
        selectedCardView = cardViews.last
        selectedCardView!.isUserInteractionEnabled = true
        selectedCardView!.addGestureRecognizer(panGesture)
        print(panGesture)
        contentViewConstraints = contentView.constraints
//        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCardView(_:)))
        
        selectedCardView!.addGestureRecognizer(longPressGesture)
        print(longPressGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentSize = CGSize(width: contentView.bounds.width, height: contentView.bounds.height)
        lastCardViewCenter = cardViews.last!.center

    }

    // MARK: - Methods
    @objc func allActionButtonClicked(_ sender: UIButton!) {
        performSegue(withIdentifier: "DepositsCardsDetailsViewController", sender: nil)
    }
    
    @objc func cardViewClicked(_ sender: UITapGestureRecognizer) {
        print("cardViewClicked")
        performSegue(withIdentifier: "DepositsCardsDetailsViewController", sender: nil)
    }
    
    @objc func longPressCardView(_ sender:UILongPressGestureRecognizer){
        print("longPressCardView")
        if sender.state == .began {
            self.selectedCardView?.removeGestureRecognizer(self.longPressGesture)
            sendMoneyButton.alpha = 0
            blockCardButton.alpha = 0
            addMoneyButton.alpha = 0

            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: .layoutSubviews,
                           animations: {
                            self.addCardButton.isHidden = true
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
        
//        UIView.transition(with: contentView, duration: 0.5, options: .transitionCrossDissolve, animations: {
//            self.addCardButton.isHidden = true
//            self.allActionButton.isHidden = false
//            self.contentViewHeightConstraint?.constant = self.scrollView.frame.height
//        })
    }
    
    @objc func dragUnselectedCardView(_ sender:UIPanGestureRecognizer){
        print("dragUnselectedCardView")
        let translation = sender.translation(in: contentView)
        let newCenterY = sender.view!.center.y + translation.y
        let newBottomY = newCenterY + sender.view!.frame.size.height/2
        let newTopY = newCenterY - sender.view!.frame.size.height/2
        let setY = (newBottomY < addCardButton.frame.origin.y && newTopY > optionPickerButton.frame.origin.y+optionPickerButton.frame.size.height) ? newCenterY : sender.view!.center.y
        sender.view?.center = CGPoint(x: sender.view!.center.x, y: setY)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        if sender.state == .ended {
            if sender.view!.center.y > self.lastCardViewCenter.y {
                UIView.animate(withDuration: 0.25,
                               delay: 0,
                               options: .curveEaseIn,
                               animations: {
                                sender.view!.center = self.lastCardViewCenter
                                //self.contentView.layoutIfNeeded()
                                
                },
                               completion: nil)
            } else {
                sendFrontCardViewToBack()
            }
        }
    }
    
    @objc func dragSelectedCardView(_ sender:UIPanGestureRecognizer){
        print("dragSelectedCardView")
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
                        for i in 0..<self.cardViewsTopConstraints.count {
                            if i == 0 {
                                self.cardViewsTopConstraints[i].constant -= 50*CGFloat(self.cardViewsTopConstraints.count-1)
                            } else {
                                self.cardViewsTopConstraints[i].constant += 50
                            }
                        }
                        self.contentView.layoutIfNeeded()
                    },
                       completion:  { (f: Bool) in
                        self.contentView.sendSubviewToBack(self.selectedCardView!)
                        self.selectedCardView?.removeGestureRecognizer(self.panGesture)
                        self.selectedCardView?.removeGestureRecognizer(self.longPressGesture)
                        self.selectedCardView = self.cardViews.last
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
                        for i in 0..<self.cardViewsTopConstraints.count {
                            if i != self.cardViewsTopConstraints.count-1 {
                                self.cardViewsTopConstraints[i].constant = 20+CGFloat(i)*50.0
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
                        self.panGesture.removeTarget(self, action: #selector(self.dragSelectedCardView(_:)))
                        self.panGesture.addTarget(self, action: #selector(self.dragUnselectedCardView(_:)))
        })
    }
    
    @objc func blockCardButtonClicked(_ sender: UIButton!) {
        performSegue(withIdentifier: "DepositsCardListOnholdBlock", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DepositsCardListOnholdBlock" {
            if let destinationVC = segue.destination as? DepositsCardsListOnholdBlockViewController {
                destinationVC.card = self.cards.last
            }
        }
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
