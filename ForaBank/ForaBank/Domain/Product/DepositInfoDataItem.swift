//
//  DepositInfoDataItem.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 2/3/22.
//

import Foundation

//TODO: use Decimal type for all financial data properties

//FIXME: rename to DepositInfoData after refactoring
struct DepositInfoDataItem: Equatable, Codable {

    let id: Int
    let initialAmount: Double
    let termDay: String?
    let interestRate: Double
    let sumPayInt: Double
    let sumCredit: Double?
    let sumDebit: Double?
    let sumAccInt: Double
    let balance: Double
    let sumPayPrc: Double?
    let dateOpen: Date
    let dateEnd: Date?
    let dateNext: Date?
}
