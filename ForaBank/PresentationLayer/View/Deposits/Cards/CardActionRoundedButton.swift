/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class CardActionRoundedButton: UIButton {
    
//    var highlightedBackgroundColor: UIColor?
//    var normalBackgroundColor: UIColor? {
//        didSet {
//            backgroundColor = normalBackgroundColor
//        }
//    }
//    var highlightedTintColor: UIColor?
//    var normalTintColor: UIColor? {
//        didSet {
//            tintColor = normalTintColor
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //print("CardActionRoundedButton init(frame: CGRect)")
        self.layer.cornerRadius = 22.5
        self.backgroundColor = .clear
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(hexFromString: "D3D3D3")!.cgColor
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.tintColor = .black
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.tintColor = defaultTintColor
            } else {
                self.tintColor = UIColor.lightGray
            }
        }
    }
    private var defaultTintColor: UIColor? = nil
    override var tintColor: UIColor! {
        didSet {
            if defaultTintColor == nil {
                defaultTintColor = tintColor
            }
            self.layer.borderColor = tintColor.cgColor
        }
    }
}
