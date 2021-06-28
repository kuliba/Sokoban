//
//  AllCardView.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.06.2021.
//

import UIKit

class AllCardView: UIView {
    
    @IBOutlet weak var button_1: UIButton!
    @IBOutlet weak var button_2: UIButton!
    @IBOutlet weak var button_3: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var buttonCollection: [UIButton]!
    
    @IBAction func selectButton(_ sender: UIButton) {
        buttonCollection.forEach{
                    $0.isSelected = false
                    $0.setImage(UIImage(named: "greyCircle"), for: .normal)
                    $0.tintColor = .lightGray
                    $0.setTitleColor(.lightGray, for: .normal)
                }

        let select = sender.tag
        sender.setImage(UIImage(named: "redCircle"), for: .normal)
        sender.tintColor = .red
        sender.setTitleColor(.black, for: .normal)
        print(select)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("AllCardView", owner: self, options: nil)
        mainView.fixView(self)
        self.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonCollection.forEach{
                    $0.isSelected = false
                    $0.setImage(UIImage(named: "greyCircle"), for: .normal)
                    $0.tintColor = .lightGray
                    $0.setTitleColor(.lightGray, for: .normal)
                    $0.centerTextAndImage(spacing: 6)
                }
    }
}

extension UIView {
    
    func fixView( _ container: UIView!) -> Void {
        
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 10).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: -10).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        
    }
    
}

extension UIButton {
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
}
