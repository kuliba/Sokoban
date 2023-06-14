//
//  TranferData+Stubs.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 01.06.2023.
//

import Foundation
@testable import ForaBank

extension TransferGeneralData {
    
    static func generalStub(
        amount: Decimal? = 0,
        phoneNumber: String? = "number"
    ) -> [TransferGeneralData] {
        
        let payer = TransferData.Payer(
            inn: nil,
            accountId: nil,
            accountNumber: nil,
            cardId: nil,
            cardNumber: nil,
            phoneNumber: "number"
        )
        
        let parameterList = [
            TransferGeneralData(
                amount: amount,
                check: false,
                comment: "comment",
                currencyAmount: "RUB",
                payer: payer,
                payeeExternal: .init(
                    inn: "7733126977",
                    kpp: "773301001",
                    accountId: nil,
                    accountNumber: "40702810238170103538",
                    bankBIC: "044525225",
                    cardId: nil,
                    cardNumber: nil,
                    compilerStatus: nil,
                    date: nil,
                    name: "Эстейт Сервис",
                    tax: nil
                ),
                payeeInternal: .init(
                    accountId: nil,
                    accountNumber: nil,
                    cardId: 1,
                    cardNumber: nil,
                    phoneNumber: "number",
                    productCustomName: "customName")
            )
        ]
        
        return parameterList
    }
}

extension TransferAnywayData {
    
    static func anywayStub() -> [TransferAnywayData] {
        
        let payer = TransferData.Payer(
            inn: nil,
            accountId: nil,
            accountNumber: nil,
            cardId: 10000184511,
            cardNumber: nil,
            phoneNumber: nil
        )
        
        let amount: Double?  = 100
        
        let parameter = TransferAnywayData(
            amount: amount,
            check: false,
            comment: nil,
            currencyAmount: "RUB",
            payer: payer,
            additional: [
                .init(fieldid: 1,
                      fieldname: "trnPickupPoint",
                      fieldvalue: "AM"),
                .init(fieldid: 1,
                      fieldname: "RecipientID",
                      fieldvalue: "number")
            ],
            puref: "iFora||MIG"
        )
        
        return [parameter]
    }
}

extension TransferMe2MeData {
    
    static func me2MeStub() -> [TransferMe2MeData] {
        
        let payer = TransferData.Payer(
            inn: nil,
            accountId: nil,
            accountNumber: nil,
            cardId: 1,
            cardNumber: nil,
            phoneNumber: nil
        )
        let amount: Double? = nil
        
        let parameterList = [
            TransferMe2MeData(
                amount: amount,
                check: false,
                comment: nil,
                currencyAmount: "RUB",
                payer: payer,
                bankId: "12345678")]
        
        return parameterList
    }
}
