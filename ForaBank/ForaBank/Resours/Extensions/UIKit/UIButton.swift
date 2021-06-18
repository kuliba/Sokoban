//
//  UIButton.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit

extension UIButton {
    
    /// Инициализатор с дополнительными параметрами
    /// по умолчанию возвращает UIButton согласно основного дизайна
    convenience init(title: String,
                     titleColor: UIColor = .white,
                     backgroundColor: UIColor = #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1),
                     isShadow: Bool = false,
                     font: UIFont? = .systemFont(ofSize: 16, weight: .regular),
                     cornerRadius: CGFloat = 22,
                     isBorder: Bool = false) {
        self.init(type: .system)
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRadius
        
        if isShadow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.2
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        if isBorder {
            self.layer.borderWidth = 1
            self.layer.borderColor = #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
        }
        
    }
    
    
}
