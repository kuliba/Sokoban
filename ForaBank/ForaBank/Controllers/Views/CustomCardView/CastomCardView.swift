//
//  CastomCardView.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.07.2021.
//

import UIKit
import IQKeyboardManagerSwift

struct CastomCardViewModel {
    var cardNumber: String = ""
    var cardName: String?
    var dateCard: String?
    var cardCVC: String?
}

class CastomCardView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet var contentView: UIView!
    
   
    @IBOutlet weak var cardTextField: MaskedTextField!
    @IBOutlet weak var dateTaxtField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var qrButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var cvcLable: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var dateLineView: UIView!
    @IBOutlet weak var cvcLineView: UIView!
    @IBOutlet weak var nameLineView: UIView!
    
    
    var closeView: (() -> Void)?
    var finishAndCloseView: ((CastomCardViewModel?) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func commonInit() {
        Bundle.main.loadNibNamed("CastomCardXIB", owner: self, options: nil)
        contentView.fixView(self)
        cardTextField.maskString = "0000 0000 0000 0000"
        dateStackView.isHidden = true
        bottomStackView.isHidden = true
        cardTextField.delegate = self
        nameTextField.delegate = self
//        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Продолжить"

        let config = IQBarButtonItemConfiguration(title: "Продолжить", action: #selector(doneButtonClicked))
        cardTextField.addKeyboardToolbarWithTarget(target: self, titleText: "Продолжить", rightBarButtonConfiguration: config)
        nameTextField.addKeyboardToolbarWithTarget(target: self, titleText: "Продолжить", rightBarButtonConfiguration: config)
//        nameTextField.addKeyboardToolbar(withTarget: self, titleText: "Продолжить" , rightBarButtonConfiguration: config, previousBarButtonConfiguration: nil, nextBarButtonConfiguration: nil)

        //  any color you like
        cardTextField.keyboardToolbar.doneBarButton.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.normal)
        nameTextField.keyboardToolbar.doneBarButton.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.normal)
        
    }
    
    @objc func doneButtonClicked() {
        guard let number = cardTextField.unmaskedText else { return }
        let model = CastomCardViewModel(cardNumber: number, cardName: nameTextField.text)
        
        finishAndCloseView?(model)
        print("DEBUG Done button tapped")
        
        
        bottomStackView.isHidden = true
        cardTextField.delegate = self
        nameTextField.delegate = self
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case cardTextField:
            if cardTextField.unmaskedText?.count == 16 {
                guard let card = cardTextField.unmaskedText else { return }
                chekClient(with: card)
                UIView.animate(withDuration: 0.2) {
                    self.qrButton.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.qrButton.alpha = 1
                }
            }
        case nameTextField:
            print(nameTextField.text ?? "")
        default:
            break
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let selelectColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        switch textField {
        case cardTextField:
            self.lineView.backgroundColor = selelectColor
        case nameTextField:
            self.nameLineView.backgroundColor = selelectColor
        default:
            break
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let unSelelectColor = #colorLiteral(red: 0.9176470588, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        switch textField {
        case cardTextField:
            self.lineView.backgroundColor = unSelelectColor
        case nameTextField:
            self.nameLineView.backgroundColor = unSelelectColor
        default:
            break
        }
    }
    
    // MARK: - IBActions
    @IBAction func qrButton(_ sender: UIButton) {
        print(#function + " Открываем экран сканера")
        let scannerView = CardScannerController.getScanner { card in
            guard let cardNumder = card else { return }
            self.cardTextField.text = "\(cardNumder)"
        }
        let top = topMostController()
        top?.present(scannerView, animated: true, completion: nil)
    }
    
    @IBAction func goBackButton(_ sender: UIButton) {
        closeView?()
    }
    @IBAction func cardTextField(_ sender: Any) {
        
    }
    
    @IBAction func dateTaxtField(_ sender: UITextField) {
        
    }
    
    @IBAction func cvcTextField(_ sender: UITextField) {
        
    }
    
    
    // MARK: - API

    private func chekClient(with number: String) {
        let body = [ "cardNumber" : number ] as [String : AnyObject]
        
        NetworkManager<CheckCardDecodableModel>.addRequest(.checkCard, [:], body) { model, error in
            DispatchQueue.main.async {
                if error != nil {
                    guard let error = error else { return }
                    print("DEBUG: ", #function, error)
                } else {
                    guard let model = model else { return }
                    guard let statusCode = model.statusCode else { return }
                    if statusCode == 0 {
                        if model.data?.check ?? false {
                            UIView.animate(withDuration: 0.2) {
                                self.bottomStackView.isHidden = false
                                self.mainStackView.layoutIfNeeded()
                            }
                            
                        }
                    } else {
                        let error = model.errorMessage ?? "nil"
                        print("DEBUG: ", #function, error)
                    }
                }
            }
        }
    }
    
}

extension UIButton {

    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
}
