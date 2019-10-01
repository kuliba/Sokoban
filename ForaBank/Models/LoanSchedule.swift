//
//  LoanSchedule.swift
//  ForaBank
//
//  Created by Дмитрий on 27/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

import Mapper

class LoanScheduleModel: Mappable {
    var actionTypeCode: Double?
    var actionTypeBrief: String?
    var actionType: String?
    var totalAmount: Double?
    var paymentAmount: Double?


    required init(map: Mapper) throws {
        try actionTypeCode = map.from("actionTypeCode")
        try actionTypeBrief = map.from("actionTypeBrief")
        try actionType = map.from("actionType")
        try totalAmount = map.from("totalAmount")
        try paymentAmount = map.from("paymentAmount")
    }
    
    func getLoanSchedule() -> Array<LaonSchedules> {
        return [LaonSchedules(title: "Доступно для снятия", value: "\(String(describing: actionTypeBrief)) \(String(describing: totalAmount))")]
      }
        

}
