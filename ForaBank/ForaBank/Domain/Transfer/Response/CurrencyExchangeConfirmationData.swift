//
//  CurrencyExchangeConfirmationData.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 07.07.2022.
//

struct CurrencyExchangeConfirmationData: Decodable, Equatable {
    
    let debitAmount: Double?
    let fee: Double?
    let creditAmount: Double?
}
