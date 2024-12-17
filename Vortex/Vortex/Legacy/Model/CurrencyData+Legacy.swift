//
//  CurrencyData+Legacy.swift
//  ForaBank
//
//  Created by Mikhail on 14.06.2022.
//

import Foundation

extension CurrencyData {
    
    func getCurrencyList() -> CurrencyList {
        
        CurrencyList(id: id, code: code, name: name, unicode: unicode, htmlCode: htmlCode, cssCode: cssCode, codeNumeric: codeNumeric, codeISO: codeISO)
    }
}
