//
//  TransferLimitData.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.08.2022.
//

import Foundation

struct TransferLimitData: Codable, Equatable {
    
    let limit: Double
    let currencyLimit: String
}
