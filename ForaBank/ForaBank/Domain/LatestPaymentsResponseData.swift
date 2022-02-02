//
//  LatestPaymentsResponseData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

class LatestPaymentsResponseData: LatestPaymentData {

	let amount: String?
	let bankId: String?
	let bankName: String?
	let phoneNumber: String?

	private enum CodingKeys : String, CodingKey {
		case amount, bankId, bankName, phoneNumber
	}

	internal init(amount: String?, bankId: String?, bankName: String?, date: Date, paymentDate: String, phoneNumber: String?, type: PaymentDataKind) {

		self.amount = amount
		self.bankId = bankId
		self.bankName = bankName
		self.phoneNumber = phoneNumber
		super.init(date: date, paymentDate: paymentDate, type: type)
	}

	required init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		amount = try container.decodeIfPresent(String.self, forKey: .amount)
		bankId = try container.decodeIfPresent(String.self, forKey: .bankId)
		bankName = try container.decodeIfPresent(String.self, forKey: .bankName)
		phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
		try super.init(from: decoder)
	}
}
