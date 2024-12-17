//
//  ForaInput.swift
//  ForaInputFactory
//
//  Created by Mikhail on 27.05.2021.
//

import UIKit

class C2BDetailsInputView: UIView {

    let kContentXibName = "C2BDetailsInput"

    var viewModel: C2BDetailsInputViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            if !viewModel.isEditable {
                textField.text = viewModel.text
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
    @IBOutlet weak var rightButton: UIButton!
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


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(viewModel: C2BDetailsInputViewModel(title: ""))
    }
    
    required init(frame: CGRect = .zero, viewModel: C2BDetailsInputViewModel) {
        super.init(frame: frame)
        commonInit(viewModel: viewModel)
    }

    
    func commonInit(viewModel: C2BDetailsInputViewModel) {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.viewModel = viewModel
        self.anchor(height: 58)
    }

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
        placeHolder.isHidden = false
        placeHolder.text = viewModel.title
    }
    
    func configCardView(_ with: GetProductListDatum) {
        viewModel.cardModel = with
        text = with.product ?? ""
        let balance = Double(with.balance ?? 0)
        balanceLabel.text = balance.currencyFormatter(symbol: with.currency ?? "")
        bottomLabelText = with.numberMasked
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

    @objc private func setupValue() {
        guard let text = textField.text else { return }
        viewModel.text = text
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
        didChooseButtonTapped?()
    }
    
    private func createBorder(for button: UIButton) {}
}
