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
    
    //MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: MaskedTextField!
    @IBOutlet weak var placeHolder: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
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
        
        textField.placeholder = viewModel.title
        textField.keyboardType = viewModel.fieldType.keyboardType
        textField.isUserInteractionEnabled = viewModel.isEditable
        textField.clearButtonMode = viewModel.needCleanButton ? .unlessEditing : .never
        rubButton.isHidden = !viewModel.showCurrencyButton
        usdButton.isHidden = !viewModel.showCurrencyButton
        chooseButton.isHidden = !viewModel.showChooseButton
        errorLabel.text = viewModel.errorText
        errorLabel.isHidden = !viewModel.needValidate
        errorLabel.alpha = 0
        bottomLabel.isHidden = !viewModel.showBottomLabel
        viewModel.isError ? showError() : nil
        
        let viewType = viewModel.fieldType.self
        switch viewType {
        case .credidCard:
            errorLabel.isHidden = true
            placeHolder.isHidden = false
        case .amountOfTransfer:
            errorLabel.isHidden = true
        default:
            placeHolder.text = viewModel.title
            placeHolder.isHidden = text.isEmpty
            placeHolder.alpha = text.isEmpty ? 0 : 1
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
            self.lineView.backgroundColor = text.isEmpty ? #colorLiteral(red: 0.9176470588, green: 0.9215686275, blue: 0.9215686275, alpha: 1) : #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
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
}


