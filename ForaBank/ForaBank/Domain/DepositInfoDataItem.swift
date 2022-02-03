//
//  DepositInfoDataItem.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 2/3/22.
//

import Foundation

struct DepositInfoDataItem: Codable, Equatable {

	let balance: Double
	let dateEnd: Date
	let dateNext: Date
	let dateOpen: Date
	let id: Int
	let initialAmount: Double
	let interestRate: Double
	let sumAccInt: Int
	let sumCredit: Double?
	let sumDebit: Double?
	let sumPayInt: Double
	let termDay: String
}
