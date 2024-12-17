//
//  UIFont+Assets.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.04.2023.
//

import UIKit

extension UIFont {
    
    /// `Text/H4/M_16×24_0%`
    static func textH4M16240() -> UIFont {
        text(ofSize: 16)
    }
    
    static func text(ofSize size: CGFloat) -> UIFont {
        
        .init(name: "Inter", size: size) ?? .systemFont(ofSize: size)
    }
}
