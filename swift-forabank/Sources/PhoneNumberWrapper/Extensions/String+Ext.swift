//
//  String+Ext.swift
//
//
//  Created by Andryusina Nataly on 19.10.2023.
//

import Foundation

extension String {
    
    func onlyDigits() -> String {
        
        let onlyDigits = self.filter(("0"..."9").contains)
        return onlyDigits.count > 10 ?
        onlyDigits.replacingOccurrences(
            of: "^0+",
            with: "",
            options: .regularExpression
        ) : onlyDigits
    }
}

extension String {
    
    func applyPatternOnPhoneNumber() -> String {
        
        guard !self.onlyDigits().isEmpty else { return "" }
        
        var number = self.onlyDigits()
        number = number.changeCodeIfNeeded()

        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end

        switch number.count {
        case 1:
            number = number.replacingOccurrences(
                of: "(\\d{1})",
                with: "+$1",
                options: .regularExpression
            )
        case 2...4:
            number = number.replacingOccurrences(
                of: "(\\d{1})(\\d+)",
                with: "+$1 $2",
                options: .regularExpression,
                range: range
            )
        case 5...7:
            number = number.replacingOccurrences(
                of: "(\\d{1})(\\d{3})(\\d+)",
                with: "+$1 $2 $3",
                options: .regularExpression,
                range: range
            )
            
        case 8...9:
            number = number.replacingOccurrences(
                of: "(\\d{1})(\\d{3})(\\d{3})(\\d+)",
                with: "+$1 $2 $3-$4",
                options: .regularExpression,
                range: range
            )
        default:
            number = number.replacingOccurrences(
                of: "(\\d{1})(\\d{3})(\\d{3})(\\d{2})(\\d+)",
                with: "+$1 $2 $3-$4-$5",
                options: .regularExpression,
                range: range
            )
        }
        return number
    }
}

extension String {
    
    func changeCodeIfNeeded() -> String {
        
        if self.hasPrefix("8") {
            return "7" + self.dropFirst(1)
        }
        return self
    }
}
