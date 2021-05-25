//
//  SBPModel.swift
//  ForaBank
//
//  Created by Дмитрий on 16.07.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class SBPModelPayment{
    var name: String?
    var amount: Int?
    var payeeName: String?
    var resultOperation: String?
    var status: String?
    var date: String?
    var accountWriteOff: String?
    var payeer: String?
    var idNumber: String?
    var bankPayeer: String?
    var message: String?
    var idOperation: String?
    init(name: String? ,amount: Int? ,payeeName: String? ,resultOperation: String? ,status: String? ,date: String? ,accountWriteOff: String?, payeer: String?, idNumber: String?, bankPayeer: String?, message:String?, idOperation:String?) {
        self.name = name
        self.amount = amount
        self.payeeName = payeeName
        self.resultOperation = resultOperation
        self.status = status
        self.date = date
        self.accountWriteOff = accountWriteOff
        self.payeer = payeeName
        self.idNumber = idNumber
        self.bankPayeer = bankPayeer
        self.message = message
        self.idOperation = idOperation
    }
    
}
