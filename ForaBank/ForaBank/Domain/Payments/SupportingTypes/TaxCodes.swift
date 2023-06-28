//
//  TaxCodes.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.06.2023.
//

enum TaxCodes {}

extension TaxCodes {
    
    #if DEBUG || MOCK
    static let avtodor = "7710965662" // test
    #else
    static let avtodor = "7707033412" // live
    #endif
}
