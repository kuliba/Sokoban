//
//  PaymentData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

class PaymentData: Codable {

	let date: Date
	let paymentDate: String
	let type: Kind

	internal init (date: Date, paymentDate: String, type: Kind) {

		self.date = date
		self.paymentDate = paymentDate
		self.type = type
	}

	private enum CodingKeys: String, CodingKey {
		case date, paymentDate, type
	}

	required init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		//date = try container.decode(Date.self, forKey: .date)
        let dateValue = try container.decode(Int.self, forKey: .date)
        date = Date(timeIntervalSince1970: TimeInterval(dateValue / 1000))
		paymentDate = try container.decode(String.self, forKey: .paymentDate)
		type = try container.decode(Kind.self, forKey: .type)
	}
}

extension PaymentData {
    
    enum Kind: String, Codable {
        case phone
        case country
        case service
        case mobile
        case internet
        case transport
        case taxAndStateService
    }
}

extension PaymentData: Equatable {

	static func == (lhs: PaymentData, rhs: PaymentData) -> Bool {
		(lhs.date == rhs.date) && (lhs.paymentDate == rhs.paymentDate) && (lhs.type == rhs.type)
	}
}
