//
//  ProductStatementData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/20/22.
//

import Foundation

struct ProductStatementData: Equatable {

	let MCC: Int?
	let accountID: Int?
	let accountNumber: String
	let amount: Double
	let cardTranNumber: String?
	let city: String?
	let comment: String
	let country: String?
	let currencyCodeNumeric: Int
	let date: String
	let deviceCode: String?
	let documentAmount: Double?
	let documentID: Int?
	let fastPayment: FastPaymentData?
	let groupName: String
	let isCancellation: Bool
	let md5hash: String
	let merchantName: String
	let merchantNameRus: String?
	let opCode: Int?
	let operationId: String?
	let operationType: OperationType
	let paymentDetailType: PaymentDetailType
	let svgImage: SVGImageData
	let terminalCode: String?
	let tranDate: String
	let type: Kind
}

extension ProductStatementData {
	
	enum OperationType: String, Codable, Equatable {

		case debit = "DEBIT"
		case credit = "CREDIT"
	}
	
	enum Kind: String, Codable, Equatable {
		
		case inside = "INSIDE"
		case outside = "OUTSIDE"
	}
}

extension ProductStatementData: Codable {

	private enum CodingKeys : String, CodingKey {

		case MCC, accountID, accountNumber, amount, cardTranNumber, city, comment, country, currencyCodeNumeric, date, deviceCode, documentAmount, documentID, fastPayment, groupName, isCancellation, md5hash, merchantName, merchantNameRus, opCode, operationId, operationType, paymentDetailType, svgImage, terminalCode, tranDate, type
	}

	init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		MCC = try container.decode(Int.self, forKey: .MCC)
		accountID = try container.decode(Int.self, forKey: .accountID)
		accountNumber = try container.decode(String.self, forKey: .accountNumber)
		amount = try container.decode(Double.self, forKey: .amount)
		cardTranNumber = try container.decode(String.self, forKey: .cardTranNumber)
		city = try container.decode(String.self, forKey: .city)
		comment = try container.decode(String.self, forKey: .comment)
		country = try container.decode(String.self, forKey: .country)
		currencyCodeNumeric = try container.decode(Int.self, forKey: .currencyCodeNumeric)
		date = try container.decode(String.self, forKey: .date)
		deviceCode = try container.decode(String.self, forKey: .deviceCode)
		documentAmount = try container.decode(Double.self, forKey: .documentAmount)
		documentID = try container.decode(Int.self, forKey: .documentID)
		fastPayment = try container.decode(FastPaymentData.self, forKey: .fastPayment)
		groupName = try container.decode(String.self, forKey: .groupName)
		isCancellation = try container.decode(Bool.self, forKey: .isCancellation)
		md5hash = try container.decode(String.self, forKey: .md5hash)
		merchantName = try container.decode(String.self, forKey: .merchantName)
		merchantNameRus = try container.decode(String.self, forKey: .merchantNameRus)
		opCode = try container.decode(Int.self, forKey: .opCode)
		operationId = try container.decode(String.self, forKey: .operationId)
		operationType = try container.decode(OperationType.self, forKey: .operationType)
		paymentDetailType = try container.decode(PaymentDetailType.self, forKey: .paymentDetailType)
		svgImage = try container.decode(SVGImageData.self, forKey: .svgImage)
		terminalCode = try container.decode(String.self, forKey: .terminalCode)
		tranDate = try container.decode(String.self, forKey: .tranDate)
		type = try container.decode(Kind.self, forKey: .type)
	}
}
