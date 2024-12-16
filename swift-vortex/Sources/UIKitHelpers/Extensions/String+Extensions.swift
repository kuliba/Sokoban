//
//  String+Extensions.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

import Foundation
import UIKit

extension String {
    
    public var htmlStringToAttributedString: NSAttributedString {
        
        guard let data = data(using: .utf8) else { return .init(string: self) }
        
        if let currentAttributedString = try? NSAttributedString(data: data,
                                                          options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
                                                          documentAttributes: nil) {
            
                
            let lineSpacing = currentAttributedString.lineSpacing()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 0 //Change space between paragraphs
            paragraphStyle.lineSpacing = lineSpacing
            
            let attributedString: NSMutableAttributedString = .init(attributedString: currentAttributedString)

            attributedString.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributedString.length))

            return attributedString
        }
        return .init(string: self)
    }
}
