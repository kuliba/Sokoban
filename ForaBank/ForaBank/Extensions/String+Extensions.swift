//
//  String+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 21.02.2022.
//

import Foundation
import CryptoKit

extension String {
    
    func contained(in list: [String]) -> Bool {
        
        for item in list {
            
            if self.contains(item) {
                
                return true
            }
        }
        
        return false
    }
        
    func masked(mask: StringValueMask) -> String {

        let value = self
        
        var maskedValue = ""
        var currentMaskIndex = 0
        
        for i in 0..<value.count {
            
            if currentMaskIndex >= mask.mask.count {
                return maskedValue
            }
            
            let currentCharacter = value[value.index(value.startIndex, offsetBy: i)]
            var maskCharacter = mask.mask[mask.mask.index(value.startIndex, offsetBy: currentMaskIndex)]
            
            if currentCharacter == maskCharacter {
                
                maskedValue.append(currentCharacter)
                
            } else {
                
                while maskCharacter != mask.symbol {
    
                    maskedValue.append(maskCharacter)
                    currentMaskIndex += 1
                    maskCharacter = mask.mask[mask.mask.index(value.startIndex, offsetBy: currentMaskIndex)]
                }
                
                maskedValue.append(currentCharacter)
            }
            
            currentMaskIndex += 1
        }
        
        return maskedValue
    }
    
    //TODO: tests
    func masked(masks: [StringValueMask]) -> String {
        
        guard self.count > 0 else {
            return self
        }
        
        let value = self
        var result: String = ""

        // sort masks by it length
        let sortedMask = masks.sorted(by: { $0.length < $1.length })
        
        var maskIndex = 0
        var currentMask = sortedMask[maskIndex]
        
        while value.count > currentMask.length && maskIndex < sortedMask.count - 1 {
            
            maskIndex += 1
            currentMask = sortedMask[maskIndex]
        }

        result = value.masked(mask: currentMask)
        
        return result
    }
    
    func isComplete(for mask: StringValueMask) -> Bool {
        
        let value = self
        
        for (maskIndex, character) in mask.mask.enumerated() {
            
            guard value.count > maskIndex else {
                return false
            }
            
            guard character != mask.symbol else {
                continue
            }
            
            let valueIndex = index(startIndex, offsetBy: maskIndex)
            
            guard value[valueIndex] == character else {
                return false
            }
        }
        
        return true
    }
    
    func filtered(regEx: String) throws -> String {
        
        let value = self
        
        let regExp = try NSRegularExpression(pattern: regEx, options: [])
        let range = NSMakeRange(0, value.count)
        let results = regExp.matches(in: value, options: [], range: range)
        
        return results.reduce("") { partialResult, result in
            
            partialResult + (value as NSString).substring(with: result.range)
        }
    }

    func filtered() -> String {
        filter { ("0"..."9").contains($0) }
    }
    
    func cropped(max: Int) -> String {
        
        let value = self
        
        guard value.digits.count > max else {
            return value
        }

        return String(value.dropLast(value.digits.count - max))
    }
    
    func sha256String() throws -> String {
        
        guard let data = data(using: .utf8) else {
            throw StringHelperError.unableCreateDataFromString
        }
        
        let digest = SHA256.hash(data: data)
        
        return digest.hexStr
    }
    
    func sha256Base64String() throws -> String {
        
        guard let data = data(using: .utf8) else {
            throw StringHelperError.unableCreateDataFromString
        }
        
        let digest = SHA256.hash(data: data)
        
        return digest.data.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    var digits: String { components(separatedBy: CharacterSet.decimalDigits.inverted).joined() }
    
    func restricted(
        withLimit limit: Int?,
        forStyle style: StringFilteringStyle
    ) -> String {
        
        let filtered: String = {
            switch style {
            case .default: return self
            case .number:  return filter(\.isNumber)
            }
        }()
        
        let limit = limit ?? count
        return String(filtered.prefix(limit))
    }
    
    func shouldChangeTextIn(
        range: NSRange,
        with replacementText: String
    ) -> String {
        
        guard
            range.location + range.length >= 0,
            let rangeStart = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex),
            let rangeEnd = index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex)
        else {
            return replacementText
        }
        
        var copy = self
        copy.replaceSubrange(rangeStart..<rangeEnd, with: replacementText)
        
        return copy
    }
}

enum StringHelperError: Error {
    
    case unableCreateDataFromString
}

enum StringFilteringStyle {
    
    case `default`, number
}

extension Optional where Wrapped == String {
    
    func updateMasked(
        inRange range: NSRange,
        update: String,
        limit: Int?,
        style: StringFilteringStyle
    ) -> String {
        
        guard let value = self else {
            return update.restricted(withLimit: limit, forStyle: style)
        }
        
        return value
            .shouldChangeTextIn(range: range, with: update)
            .restricted(withLimit: limit, forStyle: style)
    }
}

extension String {
    var isOnlyDigits: Bool {
        return self.range(
            of: "^[0-9]*$",
            options: .regularExpression) != nil
    }
}

extension String {
    var filterValue: String {
        
        if self.notContainsLetters {
            return self.filtered()
        }
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String {
    var notContainsLetters: Bool {
        let wanted = CharacterSet(charactersIn: "0123456789- +")
        return unicodeScalars
            .allSatisfy(wanted.contains)
    }
}

extension String {
    
    func addCodeRuIfNeeded() -> String {
        return (self.count == 10) ? "7" + self : self
    }
    
    func add8IfNeeded() -> String {
        return (self.count == 10) ? "8" + self : self
    }
    
    func replace7To8IfNeeded() -> String {
        return (self.count == 11 && self.hasPrefix("7")) ? "8" + self.dropFirst() : self
    }
}

extension String {
    
    static let isNeedOnboardingShow = "isNeedOnboardingShow"
}

extension String {
    
    func cardNumberMasked() -> Self {
        
        var resultString = String()
        
        self.enumerated().forEach { (index, character) in
            
            if index % 4 == 0 && index > 0 {
                resultString += " "
            }
            
            if index > 5, index < 12 {
                resultString += "*"
            } else {
                resultString.append(character)
            }
        }
        return resultString
    }
}
