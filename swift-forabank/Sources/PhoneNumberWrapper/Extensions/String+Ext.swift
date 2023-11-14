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
    
    func applyPatternOnPhoneNumber(mask: String) -> String {
        
        guard !self.onlyDigits().isEmpty else { return "" }
        
        var number = self.onlyDigits()
        number = number.changeCodeIfNeeded()
        return formatter(mask: mask)
    }
    
    func formatter (mask:String) -> String {
        
        let number = self.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression
        ).changeCodeIfNeeded()
        
        var result = ""
        var index = number.startIndex
        for character in mask where index < number.endIndex {
            if character == "X" {
                result.append(number[index])
                index = number.index(after: index)
            } else {
                result.append(character)
            }
        }
        return result
    }
    
    func getMaskedNumber() -> String {
        return self.replacingOccurrences(
            of: "[0-9]",
            with: "X",
            options: .regularExpression,
            range: nil
        )
    }
}

extension String {
    
    func changeCodeIfNeeded() -> String {
        
        if self.hasPrefix("89") {
            return "79" + self.dropFirst(2)
        }
        return self
    }
}
