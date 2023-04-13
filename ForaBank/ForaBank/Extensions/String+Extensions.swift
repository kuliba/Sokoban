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
    
    func filterred(regEx: String) throws -> String {
        
        let value = self
        
        let regExp = try NSRegularExpression(pattern: regEx, options: [])
        let range = NSMakeRange(0, value.count)
        let results = regExp.matches(in: value, options: [], range: range)
        
        return results.reduce("") { partialResult, result in
            
            partialResult + (value as NSString).substring(with: result.range)
        }
    }

    func filterred() -> String {
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
        forStyle style: TextFieldRegularView.ViewModel.Style
    ) -> String {
        
        let filtered: String = {
            switch style {
            case .number:  return filter(\.isNumber)
            case .default: return self
            }
        }()
        
        let limit = limit ?? count
        return String(filtered.prefix(limit))
    }
    
    func replacing(inRange: NSRange, with replacementText: String) -> String {
        
        guard inRange.lowerBound >= 0,
              let rangeStart = index(startIndex, offsetBy: inRange.lowerBound, limitedBy: endIndex),
              let rangeEnd = index(startIndex, offsetBy: inRange.upperBound, limitedBy: endIndex)
        else {
            return replacementText
        }
        
        var updatedValue = self
        updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: replacementText)
        
        return updatedValue
    }
}

enum StringHelperError: Error {
    
    case unableCreateDataFromString
}
