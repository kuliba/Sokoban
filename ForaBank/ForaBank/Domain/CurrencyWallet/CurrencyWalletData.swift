//
//  CurrencyWalletData.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 07.07.2022.
//

struct CurrencyWalletData: Codable, Equatable {
    
    let code: String
    let rateBuy: Double
    let rateBuyDelta: Double?
    let rateSell: Double
    let rateSellDelta: Double?
    let md5hash: String
}
