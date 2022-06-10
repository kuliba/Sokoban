//
//  LatestPaymentData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//  Refactor by Dmitry Martynov 25.05.2022
//

import Foundation

class LatestPaymentData: Codable, Identifiable {

    var id: Int { hashValue }
    let date: Date
    let paymentDate: String
    let type: Kind
    
    init (date: Date, paymentDate: String, type: Kind) {
        
        self.date = date
        self.paymentDate = paymentDate
        self.type = type
    }

	private enum CodingKeys: String, CodingKey {
		case date, paymentDate, type
	}

	required init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateValue = try container.decode(Int.self, forKey: .date)
        date = Date(timeIntervalSince1970: TimeInterval(dateValue / 1000))
		paymentDate = try container.decode(String.self, forKey: .paymentDate)
		type = try container.decode(Kind.self, forKey: .type)
	}
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(Int(date.timeIntervalSince1970) * 1000, forKey: .date)
        try container.encode(paymentDate, forKey: .paymentDate)
    }
}

extension LatestPaymentData {
    
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

extension LatestPaymentData: Equatable, Hashable {

	static func == (lhs: LatestPaymentData, rhs: LatestPaymentData) -> Bool {
		(lhs.date == rhs.date) && (lhs.paymentDate == rhs.paymentDate) && (lhs.type == rhs.type)
	}
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(date)
            hasher.combine(paymentDate)
            hasher.combine(type)
        }
}
