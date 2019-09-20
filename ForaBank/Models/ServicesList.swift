//
//  Services.swift
//  ForaBank
//
//  Created by Дмитрий on 20/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation

class Operations:Codable {
    let name: String?
    let logo: String?
    let code: String?
    let description: String?
    let order: String?
    let mcc: String?
    let mask: String?
    let isRequired: Bool?
    let isNotInTemplate: Bool?
    let rawLength: Int?
    let locale: String?
    let value: String?

    init( name: String? = nil, logo: String? = nil, code: String? = nil, description: String? = nil, order: String? = nil, mcc: String? = nil, mask: String? = nil, isRequired: Bool? = nil, isNotInTemplate: Bool? = nil, rawLength: Int? = nil, locale: String? = nil, value: String? = nil) {
        self.name = name
        self.logo = logo
        self.code = code
        self.description = description
        self.order = order
        self.mcc = mcc
        self.mask = mask
        self.isRequired = isRequired
        self.isNotInTemplate = isNotInTemplate
        self.rawLength = rawLength
        self.locale = locale
        self.value = value

    }
}
