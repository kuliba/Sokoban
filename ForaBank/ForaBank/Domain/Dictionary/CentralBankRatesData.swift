//
//  CentralBankRates.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 16.08.2022.
//

struct CentralBankRatesData: Codable, Equatable, Identifiable {
    
    var id: String { letterCode }
    
    let letterCode: String
    let numericCode: Int
    let name: String
    let rate: Double
    let unicode: String
}
