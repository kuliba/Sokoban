//
//  ForaInput.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

class ForaInput: UIView {
    
    //MARK: - Property
    let kContentXibName = "ForaInput"
    
    var viewModel: ForaInputModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            if !viewModel.isEditable {
                self.textField.text = viewModel.text
                self.placeHolder.alpha = viewModel.text.isEmpty ? 0 : 1
                self.placeHolder.isHidden = viewModel.text.isEmpty
                self.lineView.backgroundColor = viewModel.text.isEmpty ? #colorLiteral(red: 0.9176470588, green: 0.9215686275, blue: 0.9215686275, alpha: 1) : #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
                
            }
            configure()
        }
    }
    var text: String = "" {
        didSet {
            viewModel.text = text
            textField.text = text
            configure()
        }
    }
    
    var bottomLabelText: String? {
        didSet {
            guard let text = bottomLabelText else { return }
            configureBottomLabel(with: text)
        }
    }
    
    //MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: MaskedTextField!
    @IBOutlet weak var placeHolder: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var rubButton: UIButton! {
        didSet {
            
            rubButton.layer.borderWidth = 1
            rubButton.layer.borderColor = rubButton.titleLabel?.textColor.cgColor
            rubButton.layer.cornerRadius = 32 / 2
        }
    }
    @IBOutlet var chooseTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var usdButton: UIButton!{
        didSet {
            usdButton.layer.borderWidth = 1
            usdButton.layer.borderColor = usdButton.titleLabel?.textColor.cgColor
            usdButton.layer.cornerRadius = 32 / 2
        }
    }
    
    var didChooseButtonTapped: (() -> Void)?
    var didChangeValueField: ((_ field: UITextField) -> Void)?
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(viewModel: ForaInputModel(title: ""))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(viewModel: ForaInputModel(title: ""))
    }
    
    required init(frame: CGRect = .zero, viewModel: ForaInputModel) {
        super.init(frame: frame)
        commonInit(viewModel: viewModel)
    }

    
    func commonInit(viewModel: ForaInputModel) {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.viewModel = viewModel
        
        textField.addTarget(self, action: #selector(setupValue), for: .editingChanged)
        textField.delegate = self
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    //MARK: - Helpers
    private func configure() {
        
        imageView.image = viewModel.image
        balanceLabel.isHidden = true
        textField.placeholder = viewModel.title
        textField.keyboardType = viewModel.fieldType.keyboardType
        textField.isUserInteractionEnabled = viewModel.isEditable
        textField.clearButtonMode = viewModel.needCleanButton ? .unlessEditing : .never
        rubButton.isHidden = !viewModel.showCurrencyButton
        usdButton.isHidden = true //!viewModel.showCurrencyButton
        chooseButton.isHidden = !viewModel.showChooseButton
        errorLabel.text = viewModel.errorText
        errorLabel.isHidden = !viewModel.needValidate
        errorLabel.alpha = 0
        bottomLabel.isHidden = !viewModel.showBottomLabel
        viewModel.isError ? showError() : nil
        
        let viewType = viewModel.fieldType.self
        switch viewType {
        case .credidCard:
            placeHolder.text = viewModel.title
            errorLabel.isHidden = true
            placeHolder.isHidden = false
            balanceLabel.isHidden = false
            placeHolder.alpha = text.isEmpty ? 0 : 1
        case .amountOfTransfer:
            placeHolder.text = viewModel.title
            placeHolder.isHidden = false
            errorLabel.isHidden = true
            placeHolder.alpha = text.isEmpty ? 0 : 1
        case .smsCode:
            placeHolder.text = viewModel.title
            placeHolder.isHidden = false
            placeHolder.alpha = 1
            placeHolder.textColor = #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
            errorLabel.isHidden = true
            
        default:
            placeHolder.text = viewModel.title
            placeHolder.isHidden = text.isEmpty
            placeHolder.alpha = text.isEmpty ? 0 : 1
        }
        
    }
    
    func configCardView(_ with: GetProductListDatum) {
        viewModel.cardModel = with
        self.text = with.name ?? ""
        let balance = Double(with.balance ?? 0)
        self.balanceLabel.text = balance.currencyFormatter()
        self.bottomLabelText = with.numberMasked
        
    }
    
    private func configureBottomLabel(with text: String) {
        let viewType = viewModel.fieldType.self
        switch viewType {
        case .credidCard:
            let imageAttachment = NSTextAttachment()
            let firstSimb = text.first
            switch firstSimb {
            case "1":
                imageAttachment.image = #imageLiteral(resourceName: "mir-colored")
            case "4":
                imageAttachment.image = #imageLiteral(resourceName: "card_visa_logo")
            case "5":
                imageAttachment.image = #imageLiteral(resourceName: "card_mastercard_logo")
            default:
                imageAttachment.image = UIImage()
            }
            imageAttachment.bounds = CGRect(x: 0, y: 0, width: 16, height: 10)

            let attachmentString = NSAttributedString(attachment: imageAttachment)
            let completeText = NSMutableAttributedString(string: "")
            let text = NSAttributedString(string: "  *" + String(text.suffix(4)), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
            
            completeText.append(attachmentString)
            completeText.append(text)
            
            bottomLabel.attributedText = completeText
        default:
            break
        }
    }
    
    private func showError() {
        UIView.animate(withDuration: TimeInterval(0.2)) {
            self.errorLabel.alpha = !self.viewModel.text.isEmpty ? 0 : 1
            self.lineView.backgroundColor = !self.viewModel.text.isEmpty ? #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1) : #colorLiteral(red: 0.8901960784, green: 0.003921568627, blue: 0.1058823529, alpha: 1)
        }
    }
    
    //MARK: - IBAction
    @objc private func setupValue() {
        guard let text = textField.text else { return }
        viewModel.text = text
        UIView.animate(withDuration: TimeInterval(0.2)) {
//            self.errorLabel.alpha = 0
            self.placeHolder.alpha = text.isEmpty ? 0 : 1
            self.placeHolder.isHidden = text.isEmpty// ? true : false
        }
    }
    
    @IBAction func rubButtonTapped(_ sender: Any) {
        rubButton.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        rubButton.setTitleColor(#colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1), for: .normal)
        usdButton.layer.borderColor = #colorLiteral(red: 0.8274509804, green: 0.8274509804, blue: 0.8274509804, alpha: 1)
        usdButton.titleLabel?.textColor = #colorLiteral(red: 0.8274509804, green: 0.8274509804, blue: 0.8274509804, alpha: 1)
        viewModel.activeCurrency = ButtonСurrency.RUB
    }
    
    @IBAction func usdButtonTapped(_ sender: Any) {
        usdButton.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        usdButton.setTitleColor(#colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1), for: .normal)
        rubButton.layer.borderColor = #colorLiteral(red: 0.8274509804, green: 0.8274509804, blue: 0.8274509804, alpha: 1)
        rubButton.titleLabel?.textColor = #colorLiteral(red: 0.8274509804, green: 0.8274509804, blue: 0.8274509804, alpha: 1)
        viewModel.activeCurrency = ButtonСurrency.USD
    }
    
    
    
    @IBAction func chooseButtonTapped(_ sender: Any) {
//        print(#function)
        didChooseButtonTapped?()
    }
    
    private func createBorder(for button: UIButton) {
        
    }
    
}

//MARK: - UITextFieldDelegate
extension ForaInput: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if viewModel.needValidate {
            UIView.animate(withDuration: TimeInterval(0.2)) {
                self.errorLabel.alpha = !self.viewModel.text.isEmpty ? 0 : 1
                self.lineView.backgroundColor = !self.viewModel.text.isEmpty ? #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1) : #colorLiteral(red: 0.8901960784, green: 0.003921568627, blue: 0.1058823529, alpha: 1)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.lineView.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.lineView.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        didChangeValueField?(textField)
    }
}


