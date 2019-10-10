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
        let actionTypeBrief: String?
        let actionType: String?
        let paymentAmount: Double?
        let userAnnual: Double?
        let principalDebt: Double?
        let loanID: String?
        let items: [Item]
        var collapsed: Bool
        let paymentDate: String?
        
        required init(map: Mapper) throws {
            try paymentAmount = map.from("paymentAmount")
            try actionType = map.from("actionType")
            try principalDebt = map.from("principalDebt")
            try userAnnual = map.from("userAnnual")
            try loanID = map.from("loanId")
            try collapsed = map.from("collapsed")
            try actionTypeBrief = map.from("actionTypeBrief")
            try paymentDate = map.from("paymentDate")
            try items = map.from("Item.name")
        }
        init( principalDebt: Double? = nil, userAnnual: Double? = nil,  loanID: String? = nil, collapsed: Bool = true, actionTypeBrief: String? = nil, paymentDate: String? = nil, items: [Item],actionType: String? = nil, paymentAmount:Double? = nil){
            self.userAnnual = userAnnual
            self.actionType = actionType
            self.principalDebt = principalDebt
            self.loanID = loanID
            self.collapsed = collapsed
            self.actionTypeBrief = actionTypeBrief
            self.paymentDate = paymentDate
            self.items = items
            self.paymentAmount = paymentAmount


          }
}

class actionEntryList: Mappable{
    required init(map: Mapper) throws {
        try paymentAmount = map.from("")
    }
    
    let paymentAmount: Double?
    init(paymentAmount: Double? = nil) {
        self.paymentAmount = paymentAmount
    }

    
}
public struct Item: Mappable{
    var name = "123"
    let paymentAmount: Double?
    let actionTypeBrief: String?
    var detail: String
     public init(map: Mapper) throws {
        try name = map.from("name")
        try paymentAmount = map.from("paymentAmount")
        try actionTypeBrief = map.from("actionTypeBrief")
        try detail = map.from("detail")
    }
    public init(name: String, detail: String,actionTypeBrief:String, paymentAmount: Double) {
        self.name = name
        self.detail = detail
        self.paymentAmount = paymentAmount
        self.actionTypeBrief = actionTypeBrief
    }
}





