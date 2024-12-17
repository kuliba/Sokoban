//
//  PrefferedBanksList.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 23.12.2022.
//

import Foundation

struct PrefferedBanksList: Codable, Equatable {
    
    let serial: String
    let list: [String]
}
