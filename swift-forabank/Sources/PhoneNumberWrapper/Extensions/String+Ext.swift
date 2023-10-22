//
//  String+Ext.swift
//
//
//  Created by Andryusina Nataly on 19.10.2023.
//

import Foundation

extension String {
    
    func onlyDigits() -> String {
        
        self
            .filter(("0"..."9").contains)
            .replacingOccurrences(
                of: "^0+",
                with: "",
                options: .regularExpression
            )
    }
}

extension String {
    
    func applyPatternOnPhoneNumber() -> String {
        
        guard !self.onlyDigits().isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(
            pattern: "[\\s-\\(\\)]",
            options: .caseInsensitive
        ) else { return "" }
        
        let onlyDigits = self.onlyDigits()
        let r = NSString(string: onlyDigits).range(of: onlyDigits)
        var number = regex.stringByReplacingMatches(
            in: onlyDigits,
            options: .init(rawValue: 0),
            range: r,
            withTemplate: ""
        )
          
        number = number.changeCodeIfNeeded()

        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end
        

        switch number.count {
        case 1...4:
            number = number.replacingOccurrences(
                of: "(\\d{1})(\\d+)",
                with: "+$1 $2",
                options: .regularExpression,
                range: range
            )
        case 5...6:
            number = number.replacingOccurrences(
                of: "(\\d{1})(\\d{3})(\\d+)",
                with: "+$1 $2 $3",
                options: .regularExpression,
                range: range
            )
            
        case 7...8:
            number = number.replacingOccurrences(
                of: "(\\d{1})(\\d{3})(\\d{2})(\\d+)",
                with: "+$1 $2 $3-$4",
                options: .regularExpression,
                range: range
            )
        default:
            number = number.replacingOccurrences(
                of: "(\\d{1})(\\d{3})(\\d{2})(\\d{2})(\\d+)",
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
        
        if self.hasPrefix("89") {
            return "79" + self.dropFirst(2)
        }
        return self
    }
}
