//
//  RegistrationViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 14/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import DeviceKit
import FlexiblePageControl
import Hero
import IQKeyboardManagerSwift

class CardToCardUnauthorized: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: FlexiblePageControl!
    @IBOutlet weak var segmentedOuterView: UIView!
    @IBOutlet weak var scanCardButton: UIButton!

    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var payarView: CardView!

    @IBOutlet weak var payerCardView: CardView!
    @IBOutlet weak var cardNumberLabelView: UILabel!
    @IBOutlet weak var dateLabelView: UILabel!
    @IBOutlet weak var cvvLabelView: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var scanButton: UIButton!

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var centralView: UIView!
    @IBOutlet weak var secondCentralView: UIView!


    @IBOutlet weak var depositView: UIView!
    @IBOutlet weak var contractView: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!
    @IBOutlet weak var cardImage: UIImageView!
    
    @IBOutlet weak var brandLogo: UIImageView!
    @IBOutlet weak var bankLogo: UIImageView!
    @IBOutlet weak var bankLogoWidth: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var cardNumberPayer: UITextField!
    @IBOutlet weak var cardPayerLabel: UILabel!
    @IBOutlet weak var brandLogoPayer: UIImageView!
    @IBOutlet weak var bankLogoPayer: UIImageView!
    @IBOutlet weak var widthBankLogoPayer: NSLayoutConstraint!
    
    @IBOutlet weak var scanButtonPayer: UIButton!
    @IBOutlet weak var amoutTextField: UITextField!
    
    
    var previousSegment = 0

    var previousTextFieldContent: String?
    var previousSelection: UITextRange?

    var segueId: String? = nil
    var backSegueId: String? = nil

    let gradientView = UIView()
    let circleView = UIView()

    let cvcAllowedLength = 3

    var checkedCardNumber: String? = nil
    var needAnimateCard: Bool = false

    var banks: [CardBank]? = nil

    // MARK: - Actions
    @IBAction func backButtonCLicked(_ sender: Any) {
        segueId = backSegueId
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func scanCardButtonClicked(_ sender: Any) {
        view.endEditing(true)
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        
        cardIOVC?.modalPresentationStyle = .fullScreen
        cardIOVC?.collectCVV = false
        cardIOVC?.collectExpiry = false
        cardIOVC?.guideColor = UIColor(red: 0.13, green: 0.54, blue: 0.61, alpha: 1.00)
        cardIOVC?.hideCardIOLogo = true
        present(cardIOVC!, animated: true, completion: nil)
    }
    @IBAction func scanButtonPayer(_ sender: Any) {
        view.endEditing(true)
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        
        cardIOVC?.modalPresentationStyle = .fullScreen
        cardIOVC?.collectCVV = false
        cardIOVC?.collectExpiry = false
        cardIOVC?.guideColor = UIColor(red: 0.13, green: 0.54, blue: 0.61, alpha: 1.00)
        cardIOVC?.hideCardIOLogo = true
        present(cardIOVC!, animated: true, completion: nil)
    }

    @IBAction func `continue`(_ sender: Any) {
        guard let cardNumber = cardNumberTextField.text?.removeWhitespace() else {
            let alert = UIAlertController(title: "Неудача", message: "Номер карты неправильно введен", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        checkedCardNumber = cardNumber
        performSegue(withIdentifier: "loginPassword", sender: nil)
    }
    @IBAction func cardDatasChanged(_ textField: UITextField) {
        if textField.tag == 2 || textField.tag == 3,
            (textField.text?.count ?? 0) >= 2 {
        }
           

        guard let cardNumber = cardNumberTextField.text?.count, cardNumber <= 19 else {
            self.continueButton.isHidden = false
            return
        }
        if cardNumberTextField.text?.count ?? 0 == 19 {
            if textField.tag == 1 {
                UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                 
                    self.identifyBank()
                })
            } else {
                identifyBank()
            }
        } else {
            cardNumberLabelView.isHidden = false
            bankLogo.isHidden = true
            brandLogo.isHidden = true
            
         
            self.cardView.backgroundColor = .white
            self.cardView.gradientLayer.opacity = 0
            
            self.cardNumberTextField.textColor = UIColor(hexFromString: "#FFFFFF")
            self.cardNumberLabelView.textColor = UIColor(hexFromString: "#9B9B9B")

            
            
            //            self.scanCardButton.setImage(self.scanCardButton.image(for: [])?.withRenderingMode(.alwaysTemplate), for: [])
            self.scanCardButton.tintColor = UIColor(hexFromString: "#B5B5B5")

            self.cardNumberTextField.tintColor = .black
            self.cardNumberTextField.textColor = .black
            
        }
    }
    @IBAction func payerCardDatasChanged(_ textField: UITextField) {
         if textField.tag == 2 || textField.tag == 3,
             (textField.text?.count ?? 0) >= 2 {
         }
            

         guard let cardNumber = cardNumberPayer.text?.count, cardNumber <= 19 else {
             self.continueButton.isHidden = false
             return
         }
         if cardNumberPayer.text?.count ?? 0 == 19 {
             if textField.tag == 1 {
                 UIView.transition(with: payarView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                  
                     self.identifyBankPayer()
                 })
             } else {
                 identifyBankPayer()
             }
         } else {
             cardNumberPayer.isHidden = false
             bankLogoPayer.isHidden = true
             brandLogoPayer.isHidden = true
             
          
             self.payarView.backgroundColor = .white
             self.payarView.gradientLayer.opacity = 0

             self.cardNumberPayer.textColor = UIColor(hexFromString: "#9B9B9B")
            

             //            self.scanCardButton.setImage(self.scanCardButton.image(for: [])?.withRenderingMode(.alwaysTemplate), for: [])
             self.scanButtonPayer.tintColor = UIColor(hexFromString: "#FFFFFF")

             self.cardNumberPayer.tintColor = .white
             self.cardNumberPayer.textColor = .black
             
         }
     }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientLayerView()
//        addCircleView()
    
        amoutTextField.placeholder = "0"
        if amoutTextField.text?.count != 0{
            amoutTextField.backgroundColor = .clear
            amoutTextField.textColor = .white
        } else if amoutTextField.text?.count == 0{
          amoutTextField.backgroundColor = .white
            amoutTextField.textColor = .black
        }
        if pageControl != nil {
            setUpPageControl()
        }
        setUpCardNumberTextField()
        setUpCardNumberTextFieldPayer()

        setUpTextFieldDelegates()
        view.clipsToBounds = true

        if let head = header as? MaskedNavigationBar {
            head.gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            head.gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            head.gradientLayer.colors = [UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor, UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1).cgColor]
        }

        if let banksAsset = NSDataAsset(name: "banks") {
            let banksData = banksAsset.data
            let decoder = JSONDecoder()

            if let banks = try? decoder.decode(CardBanks.self, from: banksData) {
                self.banks = banks.banks
//                for b in banks.banks {
//                    print(b)

//                }
            } else {
                print("banks decoding failed")
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCardShadow()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !animated { return }
        if cardNumberTextField.text?.count ?? 0 == 75 {
            if needAnimateCard {
                UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                    self.identifyBank()
                }) { (_) in
                    self.needAnimateCard = false
                }
            } else {
                identifyBank()
            }
        }
        if cardNumberPayer.text?.count ?? 0 == 75 {
                  if needAnimateCard {
                      UIView.transition(with: payarView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                          self.identifyBankPayer()
                      }) { (_) in
                          self.needAnimateCard = false
                      }
                  } else {
                      identifyBankPayer()
                  }
              }
        if segueId == "Registration" {
            if let nav = navigationController as? ProfileNavigationController,
                pageControl != nil {
                nav.pageControl.isHidden = true
                pageControl.isHidden = false
                nav.pageControl.setCurrentPage(at: 0)
            }
            containerView.hero.id = "content"
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.beginWith([HeroModifier.opacity(1)]),
                HeroModifier.duration(0.5),
                HeroModifier.delay(0.2),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "loginPassword" {
            if let nav = navigationController as? ProfileNavigationController,
                pageControl != nil {
                if nav.pageControl.isHidden {
                    pageControl.isHidden = false
                    pageControl.hero.modifiers = [
                        HeroModifier.duration(0.5),
                        HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0))
                    ]
                } else {
                    pageControl.isHidden = true
                }
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    nav.pageControl.setCurrentPage(at: 0)
                }, completion: nil)
            }
            containerView.hero.id = "content"
            view.hero.id = "view"
            view.hero.modifiers = [
                HeroModifier.duration(0.5)
            ]
            centralView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0))
            ]
            header.hero.id = "head"
//            header.hero.modifiers = [
//                HeroModifier.duration(0.5),
//                HeroModifier.useNormalSnapshot,
//                HeroModifier.zPosition(3)
//            ]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let nav = navigationController as? ProfileNavigationController,
            pageControl != nil {
            nav.pageControl.isHidden = true
            pageControl.isHidden = false
            pageControl.hero.modifiers = nil
        }
//        _ = cardNumberTextField.becomeFirstResponder()
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView.hero.modifiers = nil
        header?.hero.modifiers = nil
        header?.hero.id = nil
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !animated { return }
        if segueId == "Registration" {
            if let nav = navigationController as? ProfileNavigationController {
                nav.pageControl.isHidden = true
                pageControl.isHidden = false
            }
            containerView.hero.id = "content"
            containerView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
            ]
            view.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.opacity(0)
            ]
        }
        if segueId == "loginPassword" {
            if pageControl != nil {
                pageControl.isHidden = true
            }
            containerView.hero.id = "content"
            view.hero.id = "view"
            view.hero.modifiers = [
                HeroModifier.duration(0.5)
            ]
            centralView.hero.modifiers = [
                HeroModifier.duration(0.5),
                HeroModifier.translate(CGPoint(x: centralView.frame.origin.x - view.frame.width, y: 0))
            ]
            header.hero.id = "head"
//            header.hero.modifiers = [
//                HeroModifier.duration(0.5),
//                HeroModifier.useNormalSnapshot,
//                HeroModifier.zPosition(3)
//            ]
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let nav = navigationController as? ProfileNavigationController {
            nav.pageControl.isHidden = true
            pageControl.isHidden = false
        }
        super.viewDidDisappear(animated)
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
        centralView.hero.modifiers = nil
        header?.hero.modifiers = nil
        header?.hero.id = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.endEditing(true)
//        IQKeyboardManager.shared.reloadLayoutIfNeeded()
        segueId = nil
        if let vc = segue.destination as? RegistrationLoginPasswordViewController {
            segueId = "loginPassword"
            vc.segueId = segueId
            vc.backSegueId = segueId
            vc.cardNumber = checkedCardNumber
        }
    }
}

// MARK: - Private methods
private extension CardToCardUnauthorized {
    func addGradientLayerView() {
        gradientView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = gradientView.frame.size
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1).cgColor, UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1).cgColor]
//        gradientLayer.colors = [UIColor(red: 237 / 255, green: 73 / 255, blue: 73 / 255, alpha: 1).cgColor, UIColor(red: 241 / 255, green: 176 / 255, blue: 116 / 255, alpha: 1).cgColor]
        gradientView.layer.addSublayer(gradientLayer)
        view.insertSubview(gradientView, at: 0)
    }

    func addCircleView() {
        circleView.frame = CGRect(x: 0, y: 0, width: view.frame.width * 5, height: view.frame.width * 5)
        circleView.center = view.center
        circleView.frame.origin.y = UIDevice.hasNotchedDisplay ? 90 : 67
        circleView.backgroundColor = .clear
        let layer = CAShapeLayer()
        layer.path = CGPath(ellipseIn: circleView.bounds, transform: nil)
        layer.fillColor = UIColor.white.cgColor
        circleView.layer.addSublayer(layer)
        circleView.clipsToBounds = true
        view.insertSubview(circleView, at: 1)
    }

    func setUpPageControl() {
        pageControl.numberOfPages = 4
        pageControl.pageIndicatorTintColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 234 / 255, green: 68 / 255, blue: 66 / 255, alpha: 1)

        let config = FlexiblePageControl.Config(
            displayCount: 4,
            dotSize: 7,
            dotSpace: 6,
            smallDotSizeRatio: 0.2,
            mediumDotSizeRatio: 0.5
        )

        pageControl.setConfig(config)
        pageControl.setCurrentPage(at: 0)
    }

    func setUpCardNumberTextField() {
        cardNumberTextField.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)

        if Device.current.isOneOf(Constants.iphone5Devices) {
            cardNumberTextField.font = cardNumberTextField.font!.withSize(14)
        }

    }
    func setUpCardNumberTextFieldPayer() {
        cardNumberPayer.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)

        if Device.current.isOneOf(Constants.iphone5Devices) {
            cardNumberPayer.font = cardNumberPayer.font!.withSize(14)
        }

        scanButtonPayer.imageView?.contentMode = .scaleAspectFit
    }

    func setCardShadow() {
        let shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 14.0)
        cardView.layer.masksToBounds = false
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 5)
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowPath = shadowPath.cgPath
    }

    @objc func reformatAsCardNumber(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }

        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }

        if cardNumberWithoutSpaces.count > 16 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }

        let cardNumberWithSpaces = insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces

        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }

    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition

        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }

        return digitsOnlyString
    }

    func insertCreditCardSpaces(_ string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        // Mapping of card prefix to pattern is taken from
        // https://baymard.com/checkout-usability/credit-card-patterns

        // UATP cards have 4-5-6 (XXXX-XXXXX-XXXXXX) format
        let is456 = string.hasPrefix("1")

        // These prefixes reliably indicate either a 4-6-5 or 4-6-4 card. We treat all these
        // as 4-6-5-4 to err on the side of always letting the user type more digits.
        let is465 = [
            // Amex
            "34", "37",

            // Diners Club
            "300", "301", "302", "303", "304", "305", "309", "36", "38", "39"
        ].contains { string.hasPrefix($0) }

        // In all other cases, assume 4-4-4-4-3.
        // This won't always be correct; for instance, Maestro has 4-4-5 cards according
        // to https://baymard.com/checkout-usability/credit-card-patterns, but I don't
        // know what prefixes identify particular formats.
        let is4444 = !(is456 || is465)

        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition

        for i in 0..<string.count {
            let needs465Spacing = (is465 && (i == 4 || i == 10 || i == 15))
            let needs456Spacing = (is456 && (i == 4 || i == 9 || i == 15))
            let needs4444Spacing = (is4444 && i > 0 && (i % 4) == 0)

            if needs465Spacing || needs456Spacing || needs4444Spacing {
                stringWithAddedSpaces.append(" ")

                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }

            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            stringWithAddedSpaces.append(characterToAdd)
        }

        return stringWithAddedSpaces
    }

    func setUpTextFieldDelegates() {
        for texfield in [cardNumberTextField] {
            texfield?.delegate = self
        }
    }
}

// MARK: - UITextFieldDelegate
extension CardToCardUnauthorized: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if (1...4).contains(textField.tag) {
            let set = CharacterSet(charactersIn: " ").union(CharacterSet.decimalDigits)
            if (string.rangeOfCharacter(from: set.inverted) != nil) {
                return false
            }
        }

        if textField.tag == 1 {
            previousTextFieldContent = textField.text
            previousSelection = textField.selectedTextRange
        }

        if textField.tag == 2 || textField.tag == 3 {
            guard let text = textField.text else { return true }
            let count = text.count + string.count - range.length
            return count <= 2
        }

        if textField.tag == 4 {
            guard let text = textField.text else { return true }
            let count = text.count + string.count - range.length
            return count <= cvcAllowedLength
        }

        return true
    }

    func identifyBank() {

        guard let cardNumber = cardNumberTextField.text?.removeWhitespace() else {
            return
        }


        brandLogo.isHidden = true
        CardBrand.allCases.forEach { (brand) in
            if cardNumber.range(of: brand.rawValue.0, options: .regularExpression, range: nil, locale: nil) != nil {
                brandLogo.image = UIImage(named: brand.rawValue.1)
                brandLogo.isHidden = false
            }
        }
        
        var identifiedBank: CardBank? = nil
        for b in banks ?? [] {
            for p in b.prefixes ?? [] {
                if cardNumber.starts(with: p) {
                    identifiedBank = b
                }
            }
        }
        cardNumberLabelView.isHidden = false
        bankLogo.isHidden = true
        self.cardView.gradientLayer.opacity = 0
        var textColor: UIColor = UIColor(hexFromString: "#9B9B9B")!
        var scanButtonColor: UIColor = UIColor(hexFromString: "#B5B5B5")!
        var tintColor: UIColor = .black
        if let bank = identifiedBank {
            if let c1 = UIColor(hexFromString: bank.backgroundColors?[0] ?? ""),
                let c2 = UIColor(hexFromString: bank.backgroundColors?[1] ?? "") {
                self.cardView.color1 = c1
                self.cardView.color1 = c2
                self.cardView.gradientLayer.opacity = 0
                self.deleteLabel.textColor = .white
            }
            if let bc = UIColor(hexFromString: bank.backgroundColor ?? "") {
                self.cardView.backgroundColor = bc
            }

            if let bankImage = UIImage(named: bank.alias ?? "") {
                bankLogo.image = bankImage
                print(bankImage.size)
                let maxHeight: CGFloat = (bankImage.size.width / bankImage.size.height > 2.4) ? 20 : 30
                bankLogoWidth.constant = bankImage.size.width * maxHeight / bankImage.size.height
                cardNumberLabelView.isHidden = true
                bankLogo.isHidden = false
            }
            if let tc = UIColor(hexFromString: bank.textColor ?? "") {
                textColor = tc
                tintColor = tc
                scanButtonColor = tc
            }
        }
        self.cardNumberLabelView.textColor = textColor
        self.dateLabelView.textColor = textColor
        self.cvvLabelView.textColor = textColor

        self.scanCardButton.tintColor = scanButtonColor

        self.cardNumberTextField.tintColor = tintColor
        self.cardNumberTextField.textColor = tintColor
        
    }
    
    
    func identifyBankPayer() {

        guard let cardNumber = cardNumberPayer.text?.removeWhitespace() else {
            return
        }


        brandLogoPayer.isHidden = true
        CardBrand.allCases.forEach { (brand) in
            if cardNumber.range(of: brand.rawValue.0, options: .regularExpression, range: nil, locale: nil) != nil {
                brandLogoPayer.image = UIImage(named: brand.rawValue.1)
                brandLogoPayer.isHidden = false
            }
        }
        
        var identifiedBank: CardBank? = nil
        for b in banks ?? [] {
            for p in b.prefixes ?? [] {
                if cardNumber.starts(with: p) {
                    identifiedBank = b
                }
            }
        }
        cardPayerLabel.isHidden = false
        bankLogoPayer.isHidden = true
        self.payarView.gradientLayer.opacity = 0
        var textColor: UIColor = UIColor(hexFromString: "#9B9B9B")!
        var scanButtonColor: UIColor = UIColor(hexFromString: "#B5B5B5")!
        var tintColor: UIColor = .black
        if let bank = identifiedBank {
            if let c1 = UIColor(hexFromString: bank.backgroundColors?[0] ?? ""),
                let c2 = UIColor(hexFromString: bank.backgroundColors?[1] ?? "") {
                self.payarView.color1 = c1
                self.payarView.color1 = c2
                self.payarView.gradientLayer.opacity = 0
                self.deleteLabel.textColor = .white
            }
            if let bc = UIColor(hexFromString: bank.backgroundColor ?? "") {
                self.payarView.backgroundColor = bc
            }

            if let bankImage = UIImage(named: bank.alias ?? "") {
                bankLogoPayer.image = bankImage
                print(bankImage.size)
                let maxHeight: CGFloat = (bankImage.size.width / bankImage.size.height > 2.4) ? 20 : 30
                widthBankLogoPayer.constant = bankImage.size.width * maxHeight / bankImage.size.height
                bankLogoPayer.isHidden = false
            }
            if let tc = UIColor(hexFromString: bank.textColor ?? "") {
                textColor = tc
                tintColor = tc
                scanButtonColor = tc
            }
        }
        self.cardPayerLabel.isHidden = true
        self.scanCardButton.tintColor = scanButtonColor

        self.cardNumberPayer.tintColor = tintColor
        self.cardNumberPayer.textColor = tintColor
        
    }
    
}

extension CardToCardUnauthorized: CardIOPaymentViewControllerDelegate {
    // Close ScanCard Screen
    public func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }

    // Using this delegate method, retrive card information
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
//            let str = String(format: "Received card info.\n Cardholders Name: %@ \n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.cardholderName,info.redactedCardNumber
//                , info.expiryMonth, info.expiryYear, info.cvv)

            //            txtCardHolderName.text = info.cardholderName
            //
            //            txtNumber.text = info.redactedCardNumber
            //
            //            txtExpiry.text = String(format:"%02lu/%lu\n",info.expiryMonth,info.expiryYear)
            //
            //            txtCvv.text = info.cvv
            var useless = 0
            cardNumberTextField.text = insertCreditCardSpaces(info.cardNumber, preserveCursorPosition: &useless)

            needAnimateCard = true
        }

        paymentViewController.dismiss(animated: true, completion: nil)
    }
}
