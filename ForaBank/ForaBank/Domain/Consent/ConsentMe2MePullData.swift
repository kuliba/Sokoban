//
//  ConsentMe2MePullData.swift
//  ForaBank
//
//  Created by Дмитрий on 20.01.2022.
//

import Foundation

struct ConsentMe2MePullData: Codable, Equatable {
    
    let active: Bool?
    let bankId: String
    let beginDate: String
    let consentId: Int
    let endDate: String
    let oneTimeConsent: Bool?
}
