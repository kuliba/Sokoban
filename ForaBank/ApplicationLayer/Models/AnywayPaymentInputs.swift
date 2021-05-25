//
//  AnywayPaymentInputs.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 02.10.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

// MARK: - AnywayPaymentInputs
class AnywayPaymentInputs: Codable {
    let data: DataClass?
    let errorMessage, result: String?

    init(data: DataClass?, errorMessage: String?, result: String?) {
        self.data = data
        self.errorMessage = errorMessage
        self.result = result
    }
}

// MARK: - DataClass
class DataClass: Codable {
    let amount, commission: Double?
    let error, errorMessage: String?
    let finalStep: Int?
    let id: String?
    let listInputs: [ListInput]?

    init(amount: Double?, commission: Double?, error: String?, errorMessage: String?, finalStep: Int?, id: String?, listInputs: [ListInput]?) {
        self.amount = amount
        self.commission = commission
        self.error = error
        self.errorMessage = errorMessage
        self.finalStep = finalStep
        self.id = id
        self.listInputs = listInputs
    }
}

// MARK: - ListInput
class ListInput: Codable {
    var content: [String]?
    var dataType, hint, id, mask: String?
    let max, min: Int?
    var name, note, onChange: String?
    let order, paramGroup: Int?
    let print, readOnly: Bool?
    let regExp: String?
    let req: Bool?
    let rightNum: Int?
    let sum, template: Bool?
    let type: String?
    let visible: Bool?
    var selectCountry : String?
    
    init(content: [String]?, dataType: String?, hint: String?, id: String?, mask: String?, max: Int?, min: Int?, name: String?, note: String?, onChange: String?, order: Int?, paramGroup: Int?, print: Bool?, readOnly: Bool?, regExp: String?, req: Bool?, rightNum: Int?, sum: Bool?, template: Bool?, type: String?, visible: Bool?, selectCountry: String) {
        self.content = content
        self.dataType = dataType
        self.hint = hint
        self.id = id
        self.mask = mask
        self.max = max
        self.min = min
        self.name = name
        self.note = note
        self.onChange = onChange
        self.order = order
        self.paramGroup = paramGroup
        self.print = print
        self.readOnly = readOnly
        self.regExp = regExp
        self.req = req
        self.rightNum = rightNum
        self.sum = sum
        self.template = template
        self.type = type
        self.visible = visible
        self.selectCountry = selectCountry
    }
}

// MARK: - Content
class Content: Codable {

    init() {
    }
}
