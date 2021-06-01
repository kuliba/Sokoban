//
//  MaskedTextField.swift
//  ForaBank
//
//  Created by Mikhail on 01.06.2021.
//

import UIKit

class MaskedTextField: UITextField {
    //MARK: - Properties
    override var text: String? {
        didSet {
            guard let text = text else { return }
            if text.last == " " || text.last == "-" {
                self.text = String(text.dropLast())
            }
        }
    }
    public private(set) var stringMask: StringMask?
    fileprivate weak var realDelegate: UITextFieldDelegate?
    public var unmaskedText: String? {
        get {
            return self.stringMask?.unmask(string: self.text) ?? self.text
        }
    }
    
    open var maskString: String? {
        didSet {
            guard let maskString = self.maskString else { return }
            self.stringMask = StringMask(mask: maskString)
        }
    }
    
    override weak open var delegate: UITextFieldDelegate? {
        get {
            return self.realDelegate
        }
        set (newValue) {
            self.realDelegate = newValue
            super.delegate = self
        }
    }
    
    //MARK: - View LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        super.delegate = self
    }
    
}

extension MaskedTextField: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.realDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.realDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return self.realDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.realDelegate?.textFieldDidEndEditing?(textField)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let previousMask = self.stringMask
        let currentText: NSString = textField.text as NSString? ?? ""
        
        if let realDelegate = self.realDelegate, realDelegate.responds(to: #selector(textField(_:shouldChangeCharactersIn:replacementString:))) {
            let delegateResponse = realDelegate.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
            
            if !delegateResponse {
                return false
            }
        }
        
        guard let mask = self.stringMask else { return true }
        
        let newText = currentText.replacingCharacters(in: range, with: string)
        var formattedString = mask.mask(string: newText)
        
        if (previousMask != nil && mask != previousMask!) || formattedString == nil {
            let unmaskedString = mask.unmask(string: newText)
            formattedString = mask.mask(string: unmaskedString)
        }
        
        guard let finalText = formattedString as NSString? else { return false }
        
        if finalText == currentText && range.location < currentText.length && range.location > 0 {
            return self.textField(textField, shouldChangeCharactersIn: NSRange(location: range.location - 1, length: range.length + 1) , replacementString: string)
        }
        
        if finalText != currentText {
            textField.text = finalText as String
            
            if range.location < currentText.length {
                var cursorLocation = 0
                
                if range.location > finalText.length {
                    cursorLocation = finalText.length
                } else if currentText.length > finalText.length {
                    cursorLocation = range.location
                } else {
                    cursorLocation = range.location + 1
                }
                guard let startPosition = textField.position(from: textField.beginningOfDocument, offset: cursorLocation) else { return false }
                guard let endPosition = textField.position(from: startPosition, offset: 0) else { return false }
                textField.selectedTextRange = textField.textRange(from: startPosition, to: endPosition)
            }
            return false
        }
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self.realDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.realDelegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.realDelegate?.textFieldDidChangeSelection?(textField)
    }
    
}
