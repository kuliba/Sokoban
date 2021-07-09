//
//  CastomCardView.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.07.2021.
//

import UIKit

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
//        bottomStackView.isHidden = true
        cardTextField.delegate = self
        nameTextField.delegate = self
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case cardTextField:
            if cardTextField.unmaskedText?.count == 16 {
                guard let card = cardTextField.unmaskedText else { return }
                chekClient(with: card)
                self.qrButton.isHidden = true
            } else {
                self.qrButton.isHidden = false
            }
        case nameTextField:
            print(nameTextField.text)
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
//        NetworkManager<CheckClientDecodebleModel>
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
