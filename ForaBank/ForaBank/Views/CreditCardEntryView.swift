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
    var orderCardTapped: (() -> Void)?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var cardNumberTextField: MaskedTextField! {
        didSet {
            cardNumberTextField.maskString = "0000 0000 0000 0000"
        }
    }
    
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
        let lineView = UIView()
        cardNumberTextField.addSubview(lineView)
        lineView.backgroundColor = .white
        lineView.anchor(top: cardNumberTextField.bottomAnchor,
                        left: cardNumberTextField.leftAnchor,
                        right: cardNumberTextField.rightAnchor,
                        paddingTop: 5 ,height: 1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
    
    @IBAction func scanerButtonTapped(_ sender: Any) {
        orderCardTapped?()
    }
    

}
