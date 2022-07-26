//
//  PhoneNumberView.swift
//  ForaBank
//
//  Created by Mikhail on 26.07.2022.
//

import UIKit
import PhoneNumberKit

class PhoneNumberView: UIView {
    
    //MARK: - Property
    let kContentXibName = "PhoneNumberView"
    
    var viewModel: PhoneNumberViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            if !viewModel.isEditable {
                textField.text = viewModel.text
                placeHolder.alpha = viewModel.text.isEmpty ? 0 : 1
                placeHolder.isHidden = viewModel.text.isEmpty
                lineView.backgroundColor = viewModel.text.isEmpty ? #colorLiteral(red: 0.9176470588, green: 0.9215686275, blue: 0.9215686275, alpha: 1) : #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
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
    
    var didChooseButtonTapped: (() -> Void)?
    var didChangeValueField: ((_ field: UITextField) -> Void)?
    
    //MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: PhoneNumberTextField!
    @IBOutlet weak var placeHolder: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var chooseButton: UIButton!
    
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(viewModel: PhoneNumberViewModel())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(viewModel: PhoneNumberViewModel())
    }
    
    required init(frame: CGRect = .zero, viewModel: PhoneNumberViewModel) {
        super.init(frame: frame)
        commonInit(viewModel: viewModel)
    }

    
    func commonInit(viewModel: PhoneNumberViewModel) {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.viewModel = viewModel
        
        textField.addTarget(self, action: #selector(setupValue), for: .editingChanged)
        textField.delegate = self
        
        self.anchor(height: 58)
        
    }
    
    //MARK: - Helpers
    private func configure() {
        imageView.image = viewModel.image
        textField.placeholder = viewModel.title
        textField.keyboardType = viewModel.fieldType.keyboardType
        textField.isUserInteractionEnabled = viewModel.isEditable
        textField.clearButtonMode = viewModel.needCleanButton ? .unlessEditing : .never
        chooseButton.isHidden = !viewModel.showChooseButton
        
        placeHolder.text = viewModel.title
        placeHolder.isHidden = text.isEmpty
        placeHolder.alpha = text.isEmpty ? 0 : 1
        
    }
    
    
    //MARK: - IBAction
    @objc private func setupValue() {
        guard let text = textField.text else { return }
        viewModel.text = text
        UIView.animate(withDuration: TimeInterval(0.2)) {
            self.placeHolder.alpha = text.isEmpty ? 0 : 1
            self.placeHolder.isHidden = text.isEmpty
        }
    }
    
    @IBAction func chooseButtonTapped(_ sender: Any) {
        didChooseButtonTapped?()
    }
}

//MARK: - UITextFieldDelegate
extension PhoneNumberView: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if viewModel.needValidate {
            UIView.animate(withDuration: TimeInterval(0.2)) {
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
