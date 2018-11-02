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

class RegistrationViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedOuterView: UIView!
    @IBOutlet weak var scanCardButton: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardNumberLabelView: UILabel!
    @IBOutlet weak var dateLabelView: UILabel!
    @IBOutlet weak var cvvLabelView: UILabel!
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var scanButton: UIButton!
    
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    var previousTextFieldContent: String?
    var previousSelection: UITextRange?
    
    let pageControl = FlexiblePageControl()
    
    weak var delegate: LoginOrSignupViewControllerDelegate?
    
    let gradientView = UIView()
    let circleView = UIView()
    
    let cvcAllowedLength = 3
    
    // MARK: - Actions
    @IBAction func backButtonCLicked(_ sender: Any) {
        delegate?.hideContainerView()
        view.endEditing(true)
        
        UIView.animate(
            withDuration: 0.35,
            animations: {
                self.registrationLabel.alpha = 0
                self.backButton.alpha = 0
                self.gradientView.alpha = 0
                self.pageControl.alpha = 0
                self.segmentedOuterView.alpha = 0
                self.cardView.alpha = 0
                self.descriptionLabel.alpha = 0
                self.continueButton.alpha = 0
                self.circleView.frame.origin.y = self.view.frame.maxY
        },
            completion: { _ in
                self.dismiss(animated: false, completion: self.delegate?.animateShowContainerView)
        })
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradientLayerView()
        addCircleView()
        
        setUpPageControl()
        setUpSegmentedControl()
        setUpCardNumberTextField()
        
        setUpTextFieldDelegates()
        
        segmentedOuterView.alpha = 0
        cardView.alpha = 0
        descriptionLabel.alpha = 0
        continueButton.alpha = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setCardShadow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.registrationLabel.alpha = 1
                self.backButton.alpha = 1
                self.pageControl.alpha = 1
                self.segmentedOuterView.alpha = 1
                self.cardView.alpha = 1
                self.descriptionLabel.alpha = 1
                self.continueButton.alpha = 1
                self.gradientView.alpha = 1
        },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.backButton.frame.origin.x -= 5
                }
        })
        
        _ = cardNumberTextField.becomeFirstResponder()
    }
}

// MARK: - Private methods
private extension RegistrationViewController {
    func addGradientLayerView() {
        gradientView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = gradientView.frame.size
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor(red: 237/255, green: 73/255, blue: 73/255, alpha: 1).cgColor, UIColor(red: 241/255, green: 176/255, blue: 116/255, alpha: 1).cgColor]
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.alpha = 0
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
        pageControl.alpha = 0
        pageControl.numberOfPages = 12
        pageControl.pageIndicatorTintColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 234/255, green: 68/255, blue: 66/255, alpha: 1)
        
        let config = FlexiblePageControl.Config(
            displayCount: 6,
            dotSize: 7,
            dotSpace: 6,
            smallDotSizeRatio: 0.5,
            mediumDotSizeRatio: 0.5
        )
        
        pageControl.setConfig(config)
        
        pageControl.center.x = view.center.x
        pageControl.frame.origin.y = 10
        containerView.addSubview(pageControl)
    }
    
    func setUpCardNumberTextField() {
        cardNumberTextField.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
        
        let iphone5Devices: [Device] = [.iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE,
                                        .simulator(.iPhone5), .simulator(.iPhone5c), .simulator(.iPhone5s), .simulator(.iPhoneSE)]
        
        if Device().isOneOf(iphone5Devices) {
            cardNumberTextField.font = cardNumberTextField.font!.withSize(14)
        }
        
        scanButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func setUpSegmentedControl() {
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(red: 86/255, green: 86/255, blue: 95/255, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
            ], for: UIControl.State.normal)
        
        segmentedControl.backgroundColor = .white
        segmentedControl.tintColor = UIColor(red: 234/255, green: 68/255, blue: 66/255, alpha: 1)
        
        segmentedOuterView.layer.cornerRadius = segmentedOuterView.bounds.height / 2
        segmentedOuterView.layer.borderColor = UIColor(red: 0.889415, green: 0.889436, blue:0.889424, alpha: 1.0 ).cgColor
        segmentedOuterView.layer.borderWidth = 1
        segmentedOuterView.layer.masksToBounds = true
        segmentedControl.setSegmentStyle()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.isUserInteractionEnabled = false
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
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if cardNumberWithoutSpaces.count > 19 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }
        
        let cardNumberWithSpaces = self.insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
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
        for texfield in [cardNumberTextField, monthTextField, yearTextField, cvvTextField] {
            texfield?.delegate = self
        }
    }
}

// MARK: - UITextFieldDelegate
extension RegistrationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 1 {
            previousTextFieldContent = textField.text
            previousSelection = textField.selectedTextRange
        }
        
        if textField.tag == 2 {
            guard let text = textField.text else { return true }
            let count = text.count + string.count - range.length
            return count <= 2
        }
        
        if textField.tag == 3 {
            if textField.text != nil {
                let newLength = textField.text!.utf16.count + string.utf16.count - range.length
                
                if newLength == cvcAllowedLength {
                    setCardToSberbank()
                }
            }
            
            guard let text = textField.text else { return true }
            let count = text.count + string.count - range.length
            return count <= cvcAllowedLength
        }
        
        return true
    }

    func setCardToSberbank() {
        cardView.backgroundColor = UIColor(red: 44/255, green: 202/255, blue: 170/255, alpha: 1)
        
        cardNumberLabelView.textColor = .white
        dateLabelView.textColor = .white
        cvvLabelView.textColor = .white
        
        scanCardButton.setImage(scanCardButton.image(for: [])?.withRenderingMode(.alwaysTemplate), for: [])
        scanCardButton.tintColor = .white
        
        cardNumberTextField.tintColor = .white
        monthTextField.tintColor = .white
        yearTextField.tintColor = .white
        cvvTextField.tintColor = .white
        
        cardNumberTextField.textColor = .white
        monthTextField.textColor = .white
        yearTextField.textColor = .white
        cvvTextField.textColor = .white
    }
}
