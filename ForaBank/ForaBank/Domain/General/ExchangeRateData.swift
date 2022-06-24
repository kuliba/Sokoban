//
//  ExchangeRateData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

struct ExchangeRateData: Codable, Equatable {

    let currency: Currency
    let currencyCode: String
    let currencyId: Int
    let currencyName: String
    let rateBuy: Double
    let rateBuyDate: Date
    let rateSell: Double
    let rateSellDate: Date
    let rateType: String
    let rateTypeId: Int
    
    enum CodingKeys : String, CodingKey {
        
        case currency = "currencyCodeAlpha"
        case currencyCode = "currencyCodeNumeric"
        case currencyId = "currencyID"
        case currencyName
        case rateBuy
        case rateBuyDate
        case rateSell
        case rateSellDate
        case rateType
        case rateTypeId = "rateTypeID"
    }
    
    init(currency: Currency, currencyCode: String, currencyId: Int, currencyName: String, rateBuy: Double, rateBuyDate: Date, rateSell: Double, rateSellDate: Date, rateType: String, rateTypeId: Int) {
        
        self.currency = currency
        self.currencyCode = currencyCode
        self.currencyId = currencyId
        self.currencyName = currencyName
        self.rateBuy = rateBuy
        self.rateBuyDate = rateBuyDate
        self.rateSell = rateSell
        self.rateSellDate = rateSellDate
        self.rateType = rateType
        self.rateTypeId = rateTypeId
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currency = try container.decode(Currency.self, forKey: .currency)
        self.currencyCode = try container.decode(String.self, forKey: .currencyCode)
        self.currencyId = try container.decode(Int.self, forKey: .currencyId)
        self.currencyName = try container.decode(String.self, forKey: .currencyName)
        self.rateBuy = try container.decode(Double.self, forKey: .rateBuy)
        let rateBuyDateValue = try container.decode(Int.self, forKey: .rateBuyDate)
        self.rateBuyDate = Date(timeIntervalSince1970: TimeInterval(rateBuyDateValue / 1000))
        self.rateSell = try container.decode(Double.self, forKey: .rateSell)
        let rateSellDateValue = try container.decode(Int.self, forKey: .rateBuyDate)
        self.rateSellDate = Date(timeIntervalSince1970: TimeInterval(rateSellDateValue / 1000))
        self.rateType = try container.decode(String.self, forKey: .rateType)
        self.rateTypeId = try container.decode(Int.self, forKey: .rateTypeId)
    }
    
    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currency, forKey: .currency)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(currencyId, forKey: .currencyId)
        try container.encode(currencyName, forKey: .currencyName)
        try container.encode(rateBuy, forKey: .rateBuy)
        try container.encode(Int(rateBuyDate.timeIntervalSince1970) * 1000, forKey: .rateBuyDate)
        try container.encode(rateSell, forKey: .rateSell)
        try container.encode(Int(rateSellDate.timeIntervalSince1970) * 1000, forKey: .rateSellDate)
        try container.encode(rateType, forKey: .rateType)
        try container.encode(rateTypeId, forKey: .rateTypeId)
    }
}
