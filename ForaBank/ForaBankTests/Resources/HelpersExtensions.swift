//
//  HelpersExtensions.swift
//  ForaBankTests
//
//  Created by Max Gribov on 17.10.2022.
//

import Foundation
@testable import ForaBank

extension Date {
    
    static func date(year: Int, month: Int, day: Int, calendar: Calendar) -> Date? {
        
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components)
    }
}

extension ProductStatementData {
    
    init(id: ProductStatementData.ID, date: Date, amount: Double, operationType: OperationType, tranDate: Date?) {
        
        self.init(mcc: nil, accountId: nil, accountNumber: "123", amount: amount, cardTranNumber: nil, city: nil, comment: "", country: nil, currencyCodeNumeric: 123, date: date, deviceCode: nil, documentAmount: nil, documentId: nil, fastPayment: nil, groupName: "", isCancellation: nil, md5hash: "", merchantName: nil, merchantNameRus: nil, opCode: nil, operationId: id, operationType: operationType, paymentDetailType: .betweenTheir, svgImage: nil, terminalCode: nil, tranDate: tranDate, type: .outside)
    }
}
