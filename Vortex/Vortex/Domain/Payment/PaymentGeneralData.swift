//
//  PaymentGeneralData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

class PaymentGeneralData: LatestPaymentData {

	let amount: String?
	let bankId: String
	let bankName: String?
	let phoneNumber: String

    var phoneNumberRu: String {
        "+7" + "\(phoneNumber)"
    }
    
	private enum CodingKeys : String, CodingKey {
		case amount, bankId, bankName, phoneNumber
	}

    init(
        id: Int = UUID().uuidString.hashValue,
        amount: String?,
        bankId: String,
        bankName: String?,
        date: Date,
        paymentDate: String,
        phoneNumber: String,
        type: Kind
    ) {

		self.amount = amount
		self.bankId = bankId
		self.bankName = bankName
		self.phoneNumber = phoneNumber
        super.init(id: id, date: date, paymentDate: paymentDate, type: type)
	}

	required init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		amount = try container.decodeIfPresent(String.self, forKey: .amount)
		bankId = try container.decode(String.self, forKey: .bankId)
		bankName = try container.decodeIfPresent(String.self, forKey: .bankName)
		phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
		try super.init(from: decoder)
	}
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(amount, forKey: .amount)
        try container.encode(bankId, forKey: .bankId)
        try container.encodeIfPresent(bankName, forKey: .bankName)
        try container.encode(phoneNumber, forKey: .phoneNumber)

        try super.encode(to: encoder)
    }
}
