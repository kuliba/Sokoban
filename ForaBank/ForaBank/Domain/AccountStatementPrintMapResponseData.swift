//
//  AccountStatementPrintMapResponseData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/20/22.
//

import Foundation

struct StatementObjectData: Codable, Equatable {
	
	let amount: Double
	let comment: String
	let lineNumber: Int
	let operationDate: String
	let operationType: String
	let tranDate: String
	let tranTime: String
}

struct AccountStatementPrintMapResponseData: Codable, Equatable {
	
	let balanceIn: Double
	let balanceOut: Double
	let endDate: String
	let payerAccountNumber: String
	let payerCurrency: String
	let payerFullName: String
	let productStatementList: [StatementObjectData]
	let responseDate: String
	let startDate: String
	let totalCredit: Double
	let totalDebit: Double
	let transferDate: String
}
