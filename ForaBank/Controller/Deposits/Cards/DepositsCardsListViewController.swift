//
//  DepositsCardsListViewController.swift
//  ForaBank
//
//  Created by Sergey on 16/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsCardsListViewController: UIViewController {
    
    var panGesture       = UIPanGestureRecognizer()
    var lastCardViewCenter: CGPoint = CGPoint.zero
    var firstCardViewCenter: CGPoint = CGPoint.zero
    var selectedCardView: DetailedCardView? = nil
    
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
//    let cardsStackView: UIStackView = {
//        let csv = UIStackView()
//        csv.backgroundColor = .blue
//        csv.axis = .vertical;
//        csv.distribution = .fillEqually;
//        csv.alignment = .center;
//        //csv.spacing = -100;
//        csv.translatesAutoresizingMaskIntoConstraints = false
//        return csv
//    }()
    let sortPickerButton: PickerButton = {
        let b = PickerButton(type: .system)
        b.tintColor = .black
        b.setTitle("Сортировать по состоянию счета", for: .normal)
        //b.setTitleColor(UIColor.black, for: .normal)
        b.contentHorizontalAlignment = .left
        b.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(sortPickerButton)
        //reasonPickerButton.addTarget(self, action: #selector(reasonPickerButtonClicked(_:)), for: .touchUpInside)
        
        //addCardButton
        contentView.addSubview(addCardButton)
        // constrain addCardButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[addCardButton]-20-|", options: [], metrics: nil, views: ["addCardButton":addCardButton])
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[addCardButton(45)]-20-|", options: [], metrics: nil, views: ["addCardButton":addCardButton])
        contentView.addConstraints(horizontalConstraints)
        contentView.addConstraints(verticalConstraints)
        
        // constrain sortPickerButton
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[sortPickerButton]-20-|", options: [], metrics: nil, views: ["sortPickerButton":sortPickerButton])
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[sortPickerButton(35)]", options: [], metrics: nil, views: ["sortPickerButton":sortPickerButton])
        contentView.addConstraints(horizontalConstraints)
        contentView.addConstraints(verticalConstraints)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if cardViews.count != 0 {
            return
        }
        
        if CardManager.shared().hasBlockedCard {
            cards = CardManager.shared().cards.reversed()
        } else {
            cards = CardManager.shared().cards
        }
        let cardWidth = UIScreen.main.bounds.width - 40
        let cardHeight = CGFloat(cardWidth)*160/280
        let cardsCount = CGFloat(cards.count)
//        cardsStackView.spacing = 40-cardHeight
        let cardsStackHeight = cardsCount*(cardHeight)+(cardsCount-1)*(50-cardHeight)
//        print(UIScreen.main.bounds)
//        print(sortPickerButton.bounds)
//        print(cardWidth)
//        print(cardHeight)
//        print(cardsCount)
//        print(cardsStackHeight)
        scrollView.addConstraint(NSLayoutConstraint(item: contentView,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1,
                                                    constant: cardsStackHeight+180))
        //cardsStackView
//        contentView.addSubview(cardsStackView)
        //CardViews
        for (i, c) in cards.enumerated() {
            let cardView = DetailedCardView()
            let foregroundColor = (c.type.rawValue.range(of: "mastercard") != nil) ? UIColor.black : UIColor.white
            cardView.titleLabel.attributedText = NSAttributedString(string: c.title, attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor : foregroundColor])
            //cardView.titleLabel.sizeToFit()
            cardView.cardCashLabel.attributedText = NSAttributedString(string: c.cash, attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor : foregroundColor])
            cardView.backgroundImageView.image = UIImage(named: c.type.rawValue)
            cardView.cardNumberLabel.attributedText = NSAttributedString(string: c.number, attributes: [.font:UIFont.systemFont(ofSize: 12), .foregroundColor : foregroundColor])
            cardView.cardValidityPeriodLabel.attributedText = NSAttributedString(string: c.validityPeriod, attributes: [.font:UIFont.systemFont(ofSize: 12), .foregroundColor : foregroundColor])
            if c.type.rawValue.range(of: "visa") != nil {
                cardView.logoImageView.image = UIImage(named: "card_visa_logo")
            }
            else if c.type.rawValue.range(of: "mastercard") != nil {
                cardView.logoImageView.image = UIImage(named: "card_mastercard_logo")
            }
            
            if c.paypass {
                cardView.paypassLogoImageView.image = UIImage(named: "card_paypass_logo")
            }
            if c.blocked {
                cardView.cardBlockedImageView.image = UIImage(named: "card_blocked")
            }
            
//            cardsStackView.addArrangedSubview(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
//            cardsStackView.addConstraint(NSLayoutConstraint(item: cardView,
//                                                            attribute: .width,
//                                                            relatedBy: .equal,
//                                                            toItem: nil,
//                                                            attribute: .notAnAttribute,
//                                                            multiplier: 1,
//                                                            constant: cardWidth))
//            cardsStackView.addConstraint(NSLayoutConstraint(item: cardView,
//                                                            attribute: .height,
//                                                            relatedBy: .equal,
//                                                            toItem: nil,
//                                                            attribute: .notAnAttribute,
//                                                            multiplier: 1,
//                                                            constant: cardHeight))
            contentView.addSubview(cardView)
            //let metrics = ["cardHeight" : cardHeight]
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[cardView]-20-|", options: [], metrics: nil, views: ["cardView":cardView])
            contentView.addConstraints(horizontalConstraints)
            contentView.addConstraint(NSLayoutConstraint(item: cardView,
                                                        attribute: .top,
                                                        relatedBy: .equal,
                                                        toItem: sortPickerButton,
                                                        attribute: .bottom,
                                                        multiplier: 1,
                                                        constant: 20+CGFloat(i)*50.0))
            contentView.addConstraint(NSLayoutConstraint(item: cardView,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .height,
                                                         multiplier: 1,
                                                         constant: cardHeight))
            if i==cards.count-1 {
                //print(cardView)
                let gesture = UITapGestureRecognizer(target: self, action: #selector (cardViewClicked (_:)))
                cardView.addGestureRecognizer(gesture)
            }
            cardViews.append(cardView)
        }
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        selectedCardView = cardViews.last
        selectedCardView!.isUserInteractionEnabled = true
        selectedCardView!.addGestureRecognizer(panGesture)
//        print(cardViews.last?.isUserInteractionEnabled as Any)
//        let swipeDown = UISwipeGestureRecognizer.init(target: self, action: #selector(testSwipe(_:)))
//        swipeDown.direction = .down
//        cardViews.last?.addGestureRecognizer(swipeDown)
        
        // constrain cardsStackView
//        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardsStackView]-0-|", options: [], metrics: nil, views: ["cardsStackView":cardsStackView])
//        contentView.addConstraints(horizontalConstraints)
//        contentView.addConstraint(NSLayoutConstraint(item: cardsStackView,
//                                                     attribute: .top,
//                                                     relatedBy: .equal,
//                                                     toItem: sortPickerButton,
//                                                     attribute: .bottom,
//                                                     multiplier: 1,
//                                                     constant: 20))
//        contentView.addConstraint(NSLayoutConstraint(item: cardsStackView,
//                                                    attribute: .height,
//                                                    relatedBy: .equal,
//                                                    toItem: nil,
//                                                    attribute: .notAnAttribute,
//                                                    multiplier: 1,
//                                                    constant: cardsStackHeight))
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentSize = CGSize(width: contentView.bounds.width, height: contentView.bounds.height)
        lastCardViewCenter = cardViews.last!.center
        firstCardViewCenter = cardViews.first!.center
        print(lastCardViewCenter)
        print(firstCardViewCenter)
//        print(scrollView.contentSize)
//        print(contentView.bounds)
//        print(cardsStackView.bounds)
//        print(cardsStackView.subviews)
//        print(cardsStackView.layoutMargins)
    }

    // MARK: - Methods
    @objc func cardViewClicked(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "CardListOnholdNavigation", sender: nil)
    }
    
    @objc func testSwipe(_ g: UISwipeGestureRecognizer) {
        print("swipeDown")
    }
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        //self.view.bringSubviewToFront(sender.view!)
        let translation = sender.translation(in: contentView)
//        cardViews.last?.center = CGPoint(x: cardViews.last!.center.x + translation.x, y: cardViews.last!.center.y + translation.y)
        let newCenterY = sender.view!.center.y + translation.y
        let newBottomY = newCenterY + sender.view!.frame.size.height/2
        let newTopY = newCenterY - sender.view!.frame.size.height/2
        let setY = (newBottomY < addCardButton.frame.origin.y && newTopY > sortPickerButton.frame.origin.y+sortPickerButton.frame.size.height) ? newCenterY : sender.view!.center.y
        sender.view?.center = CGPoint(x: sender.view!.center.x, y: setY)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        if sender.state == .ended {
            if sender.view!.center.y > self.lastCardViewCenter.y {
                UIView.animate(withDuration: 0.25,
                               delay: 0,
                               options: .curveEaseIn,
                               animations: {sender.view!.center = self.lastCardViewCenter},
                               completion: nil)
            } else {
                sendFrontCardViewToBack()
            }
        }
    }
    
    func sendFrontCardViewToBack() {
        print(cards)
        print(cardViews)
        let tempCard = cards.last
        cards[cards.count-1] = cards[0]
        cards[0] = tempCard!
        let tempCardView = cardViews.last
        cardViews[cardViews.count-1] = cardViews[0]
        cardViews[0] = tempCardView!
        print(cards)
        print(cardViews)
//        UIView.animate(withDuration: 1,
//                       delay: 0,
//                       options: .beginFromCurrentState,
//                       animations: {
//                        for (i,c) in self.cardViews.enumerated() {
//                            if i == self.cardViews.count-1 {
//                                c.frame.origin.y = self.firstCardViewCenter.y
//                            } else {
//                                c.frame.origin.y += 50
//                            }
//                        }
//
//                    },
//                       completion:  { (f: Bool) in self.contentView.sendSubviewToBack(self.selectedCardView!)
//                        //print(self.cards)
//                        print(self.cardViews)
//        })
    }
}
