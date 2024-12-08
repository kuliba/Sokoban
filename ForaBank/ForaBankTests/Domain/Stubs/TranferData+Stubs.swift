//
//  TranferData+Stubs.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 01.06.2023.
//

import Foundation
@testable import Vortex

extension TransferGeneralData.PayeeExternal {

    static func stub(
        inn: String = "7733126977",
        kpp: String = "773301001",
        accountNumber: String = "40702810238170103538",
        bankBIC: String = "044525225",
        name: String = "ForaService"
    ) -> TransferGeneralData.PayeeExternal {
        
            return .init(
                inn: inn,
                kpp: kpp,
                accountId: nil,
                accountNumber: accountNumber,
                bankBIC: bankBIC,
                cardId: nil,
                cardNumber: nil,
                compilerStatus: nil,
                date: nil,
                name: name,
                tax: nil
            )
        }
}

extension TransferGeneralData {
    
    static func generalStub(
        payeeExternal: TransferGeneralData.PayeeExternal? = .stub(),
        amount: Decimal? = 0,
        phoneNumber: String? = "11111",
        cardId: Int = 1
    ) -> [TransferGeneralData] {
        
        let payer = TransferData.Payer(
            inn: "inn",
            accountId: 1,
            accountNumber: "accountNumber",
            cardId: cardId,
            cardNumber: nil,
            phoneNumber: phoneNumber
        )
        
        let parameterList = [
            TransferGeneralData(
                amount: amount,
                check: false,
                comment: "comment",
                currencyAmount: "RUB",
                payer: payer,
                payeeExternal: payeeExternal,
                payeeInternal: .init(
                    accountId: nil,
                    accountNumber: nil,
                    cardId: 1,
                    cardNumber: "cardNumber",
                    phoneNumber: phoneNumber,
                    productCustomName: "customName")
            )
        ]
        
        return parameterList
    }
}

extension TransferAnywayData {
    
    static func anywayStub(
        amount: Double? = 100,
        cardId: Int = 10000184511
    ) -> [TransferAnywayData] {
        
        let payer = TransferData.Payer(
            inn: nil,
            accountId: nil,
            accountNumber: nil,
            cardId: cardId,
            cardNumber: nil,
            phoneNumber: nil
        )
        
        let parameter = TransferAnywayData(
            amount: amount,
            check: false,
            comment: nil,
            currencyAmount: "RUB",
            payer: payer,
            additional: .stub(),
            puref: "iVortex||MIG"
        )
        
        return [parameter]
    }
}

extension Array where Element == TransferAnywayData.Additional {
    
    static func stub() -> [TransferAnywayData.Additional] {
        
        
        return [
            .init(fieldid: 1,
                  fieldname: "trnPickupPoint",
                  fieldvalue: "AM"),
            .init(fieldid: 1,
                  fieldname: "RecipientID",
                  fieldvalue: "123123")
        ]
    }
}

extension TransferMe2MeData {
    
    static func me2MeStub(
        accountId: Int? = nil,
        cardId: Int? = nil,
        amount: Decimal? = nil
    ) -> [TransferMe2MeData] {
        
        return [
            TransferMe2MeData(
                amount: amount,
                check: false,
                comment: nil,
                currencyAmount: "RUB",
                payer: .sample(
                    accountId: accountId,
                    cardId: cardId
                ),
                bankId: "12345678")
        ]
    }
}

extension TransferData.Payer {
    
    static func sample(
        accountId: Int? = nil,
        cardId: Int? = nil
    ) -> Self {
        
        .init(
            inn: nil,
            accountId: accountId,
            accountNumber: nil,
            cardId: cardId,
            cardNumber: nil,
            phoneNumber: nil
        )
    }
}
