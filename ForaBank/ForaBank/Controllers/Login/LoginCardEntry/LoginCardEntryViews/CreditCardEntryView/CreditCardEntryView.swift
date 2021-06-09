//
//  CreditCardEntryView.swift
//  ForaBank
//
//  Created by Mikhail on 31.05.2021.
//

import UIKit

class CreditCardEntryView: UIView {

    //MARK: - Property
    let kContentXibName = "CreditCardEntryView"
    
    /// Замыкание для действия по нажатию кнопки сканера
    var scanerCardTapped: (() -> Void)?
    /// Замыкание для действия по нажатию кнопки готово
    var enterCardNumberTapped: ((String) -> Void)?
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var cardNumberTextField: MaskedTextField! 
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
    
    @IBAction func scanerButtonTapped(_ sender: Any) {
        scanerCardTapped?()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let text = cardNumberTextField.text else { return }
        enterCardNumberTapped?(text)
    }
    
}
