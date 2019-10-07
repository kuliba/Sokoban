//
//  File.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import Mapper

class AboutItem: IAboutItem {
    let title: String
    let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}



    class LaonSchedules: Mappable {
        var actionTypeCode: Double?
        var actionTypeBrief: String?
        var actionType: String?
        var totalAmount: Double?
        var paymentAmount: Double?
        var dateValue: String?
        var userAnnual: Double?
        var number: String?
        var principalDebt: Double?
        var loanID: Int?

        required init(map: Mapper) throws {
            try actionTypeCode = map.from("actionTypeCode")
            try actionTypeBrief = map.from("actionTypeBrief")
            try actionType = map.from("actionType")
            try totalAmount = map.from("totalAmount")
            try paymentAmount = map.from("paymentAmount")
            try principalDebt = map.from("principalDebt")
            try number = map.from("number")
            try userAnnual = map.from("userAnnual")
            try loanID = map.from("loanId")
        }
        init( principalDebt: Double? = nil, userAnnual: Double? = nil, number: String? = nil, DateValue: String? = nil) {
            self.userAnnual = userAnnual
            self.principalDebt = principalDebt
          }
        
     
            

    


}

