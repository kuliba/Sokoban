//
//  UILabel.swift
//  ForaBank
//
//  Created by Mikhail on 31.05.2021.
//

import UIKit

extension UILabel {
    
    /// Инициализатор с дополнительными параметрами
    convenience init(text: String,
                     font: UIFont? = .systemFont(ofSize: 14),
                     color: UIColor? = UIColor.init(named: "textColorFora")) {
        self.init(frame: .zero)
        self.font = font
        self.text = text
        self.textColor = color
        self.sizeToFit()
    }
}
