//
//  NSAttributedString+Extensions.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

import Foundation
import UIKit

extension NSAttributedString {
    
    public func lineSpacing() -> CGFloat {
        
        var range = NSMakeRange(0, self.length)
        if let currentParagraphStyle = self.attribute(
            NSAttributedString.Key.paragraphStyle,
            at: 0, effectiveRange: &range
        ) as? NSParagraphStyle {
            
            return currentParagraphStyle.lineSpacing
        }
        return 0
    }
}
