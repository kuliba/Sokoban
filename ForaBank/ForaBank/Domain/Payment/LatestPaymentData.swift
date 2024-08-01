//
//  LatestPaymentData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//  Refactor by Dmitry Martynov 25.05.2022
//

import Foundation

class LatestPaymentData: Codable, Identifiable {
    
    let id: Int
    let date: Date
    let paymentDate: String
    let type: Kind
    
    init(
        id: Int = UUID().uuidString.hashValue,
        date: Date,
        paymentDate: String,
        type: Kind
    ) {
        
        self.id = UUID().uuidString.hashValue
        self.date = date
        self.paymentDate = paymentDate
        self.type = type
    }

	private enum CodingKeys: String, CodingKey {
		case date, paymentDate, type
	}

	required init(from decoder: Decoder) throws {

        id = UUID().uuidString.hashValue
		let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateValue = try container.decode(Int.self, forKey: .date)
        date = Date.dateUTC(with: dateValue)
		paymentDate = try container.decode(String.self, forKey: .paymentDate)
		type = try container.decode(Kind.self, forKey: .type)
	}
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(date.secondsSince1970UTC, forKey: .date)
        try container.encode(paymentDate, forKey: .paymentDate)
    }
}

extension LatestPaymentData {
    
    enum Kind: String, Codable, Unknownable {
        
        case phone
        case service
        case mobile
        case internet
        case transport
        case taxAndStateService
        case outside
        case unknown
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

 //MARK: Helpers

extension LatestPaymentData {
    
    func getServiceIdentifierForTaxService() throws -> Payments.Service {
        
        guard let latestPayment = self as? PaymentServiceData,
              let `operator` = Payments.Operator(rawValue: latestPayment.puref)
        else {
            throw Payments.Error.unsupported
        }
        
        switch `operator` {
        case .fms:
            return .fms
            
        case .fns, .fnsUin:
            return .fns
            
        case .fssp:
            return .fssp
            
        default:
            throw Payments.Error.unsupported
        }
    }
}
