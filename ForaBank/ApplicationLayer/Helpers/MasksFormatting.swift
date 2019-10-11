//
//  MasksFormatting.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation

/// String cleaners

func cleanNumberString(string: String) -> String {
    let cs = CharacterSet(charactersIn: "0123456789")
    return string.components(separatedBy: cs.inverted).joined()
}

/// Formating

func formatedCreditCardString(creditCardString: String) -> String {
    let trimmedString = creditCardString.components(separatedBy: .whitespaces).joined()

    let arrOfCharacters = Array(trimmedString)
    var modifiedCreditCardString = ""

    if(arrOfCharacters.count > 0) {
        for i in 0...arrOfCharacters.count - 1 {
            modifiedCreditCardString.append(arrOfCharacters[i])
            if((i + 1) % 4 == 0 && i + 1 != arrOfCharacters.count) {
                modifiedCreditCardString.append(" ")
            }
        }
    }
    return modifiedCreditCardString
}

func formattedPhoneNumber(number: String) -> String {
    let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let mask = "+X (XXX) XXX-XXXX"

    var result = ""
    var index = cleanPhoneNumber.startIndex
    for ch in mask where index < cleanPhoneNumber.endIndex {
        
        if ch == "X" {
            result.append(cleanPhoneNumber[index])
            index = cleanPhoneNumber.index(after: index)
        } else {
            result.append(ch)
        }
    }
    return result
}

// Numbers masks

func maskedString(string: String, mask: Array<Int>, separator: String) -> String {
    var temp = string.map { String($0) }
    let parts = mask.map { (item) -> [String] in
        let part = temp[0...item - 1]
        temp = Array(temp.suffix(from: item))
        return Array(part)
    }

    let joinedParts = parts.map({ $0.joined() })
    return Array(joinedParts).joined(separator: separator)
}

func dotMaskedString(string: String, mask: Array<Int>) -> String {
    return maskedString(string: string, mask: mask, separator: "•")
}

func maskedAccount(with string: String) -> String {
    let mask = [5, 3, 1, 4, 7]
    return dotMaskedString(string: string, mask: mask)
}

func maskedCard(with string: String) -> String {
    let mask = [4, 4, 4, 4]
    return dotMaskedString(string: string, mask: mask)
}

//Money

func maskSum(sum: Double) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale(identifier: "ru_RU")
    currencyFormatter.currencySymbol = ""

    if let formattedSum = currencyFormatter.string(from: NSNumber(value: sum)) {
        return formattedSum
    }
    return String(sum)
}
