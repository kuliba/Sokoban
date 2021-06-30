//
//  SeparatorView.swift
//  ForaBank
//
//  Created by Mikhail on 27.06.2021.
//

import UIKit

class SeparatorView: UIView {
    
    //MARK: - Property
    let kContentXibName = "SeparatorView"
    var buttonSwitchCardTapped: (() -> Void)?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var straightLineView: UIView! {
        didSet { straightLineView.isHidden = true }
    }
    @IBOutlet weak var curvedLineView: UIImageView!

    @IBOutlet weak var changeAccountButton: UIButton! {
        didSet {
            changeAccountButton.layer.borderWidth = 1
            changeAccountButton.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            changeAccountButton.layer.cornerRadius = 32 / 2
            changeAccountButton.isHidden = true
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        self.buttonSwitchCardTapped?()
    }
    
    
    //MARK: - Viewlifecicle
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
        self.anchor(height: 28)
        
    }
    
}
