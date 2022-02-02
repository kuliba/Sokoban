//
//  LatestPaymentData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

class LatestPaymentData: Codable {

	let date: Date
	let paymentDate: String
	let type: PaymentDataKind

	internal init (date: Date, paymentDate: String, type: PaymentDataKind) {

		self.date = date
		self.paymentDate = paymentDate
		self.type = type
	}

	private enum CodingKeys : String, CodingKey {
		case date, paymentDate, type
	}

	required init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		date = try container.decode(Date.self, forKey: .date)
		paymentDate = try container.decode(String.self, forKey: .paymentDate)
		type = try container.decode(PaymentDataKind.self, forKey: .type)
	}
}

extension LatestPaymentData: Equatable {

	static func == (lhs: LatestPaymentData, rhs: LatestPaymentData) -> Bool {
		(lhs.date == rhs.date) && (lhs.paymentDate == rhs.paymentDate) && (lhs.type == rhs.type)
	}
}
