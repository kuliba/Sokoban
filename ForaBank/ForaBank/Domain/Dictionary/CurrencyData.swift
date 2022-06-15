//
//  CurrencyCode.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct CurrencyData: Codable, Equatable {
    
    let code: String
    let codeISO: Int
    let codeNumeric: Int
    let cssCode: String?
    let htmlCode: String?
    let id: String
    let name: String
    let unicode: String?
}

extension CurrencyData {
    
    var currencySymbol: String? {
        
        guard let unicodeData = cssCode?.components(separatedBy: "\\").last,
              let unicodeValue = UInt32(unicodeData, radix: 16),
              let unicodeScalar = UnicodeScalar(unicodeValue) else {
            
            return nil
        }
        
        return String(unicodeScalar)
    }
}
