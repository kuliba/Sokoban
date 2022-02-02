//
//  LatestServicePaymentsResponseData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

class LatestServicePaymentsResponseData: LatestPaymentData {

	var additionalList: [AdditionalListData]
	var amount: Double
	var puref: String
	
	private enum CodingKeys : String, CodingKey {
		case additionalList, amount, puref
	}
	
	internal init(additionalList: [AdditionalListData], amount: Double, date: Date, paymentDate: String, puref: String, type: PaymentDataKind) {
		
		self.additionalList = additionalList
		self.amount = amount
		self.puref = puref
		super.init(date: date, paymentDate: paymentDate, type: type)
	}
	
	required init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		additionalList = try container.decode([AdditionalListData].self, forKey: .additionalList)
		amount = try container.decode(Double.self, forKey: .amount)
		puref = try container.decode(String.self, forKey: .puref)

		try super.init(from: decoder)
	}
}

extension LatestServicePaymentsResponseData {

	struct AdditionalListData: Codable, Equatable {
		
		let fieldTitle: String
		let fieldName: String
		let fieldValue: String
		let svgImage: String?
	}
}
