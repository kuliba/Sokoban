//
//  ResultAccountStatementModel.swift
//  ForaBank
//
//  Created by Mikhail on 18.11.2021.
//

import Foundation

class ResultAccountStatementModel {
    
    private let formatter = Date.dateLondonFormatterSimpleDate()
    let product: UserAllCardsModel
    var startDate: String
    var endDate: String
    
    init?(product: UserAllCardsModel, statTime: Date, endTime: Date) {
        self.product = product
        self.startDate = formatter.string(from: statTime)
        self.endDate = formatter.string(from: endTime)
    }
}
