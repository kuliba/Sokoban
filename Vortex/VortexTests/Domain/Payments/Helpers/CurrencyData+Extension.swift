//
//  CurrencyData+Extension.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 21.02.2023.
//

@testable import ForaBank

extension CurrencyData {
    
    // ▿ 76 : CurrencyData
    //   - code : "RUB"
    //   - codeISO : 643
    //   - codeNumeric : 810
    //   ▿ cssCode : Optional<String>
    //     - some : "\\20BD"
    //   ▿ htmlCode : Optional<String>
    //     - some : "&#8381;"
    //   - id : "2"
    //   - name : "Российский рубль"
    //   - shortName : nil
    //   ▿ unicode : Optional<String>
    //     - some : "U+20BD"
    static let rub: Self = .init(code: "RUB", codeISO: 643, codeNumeric: 810, cssCode: "\\20BD", htmlCode: "&#8381;", id: "2", name: "Российский рубль", shortName: nil, unicode: "U+20BD")
}
