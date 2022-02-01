//
//  RatesExchangeData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

struct RatesExchangeData: Codable, Equatable {
    
    let currencyCodeAlpha: String
    let currencyCodeNumeric: String
    let currencyID: Int
    let currencyName: String
    let rateBuy: Double
    let rateBuyDate: Date
    let rateSell: Double
    let rateSellDate: Date
    let rateType: String
    let rateTypeID: Int
}
