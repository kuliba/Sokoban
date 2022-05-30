//
//  PaymentCountryData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

class PaymentCountryData: LatestPaymentData {

	let countryCode: String
	let countryName: String
	let firstName: String?
	let middleName: String?
	let phoneNumber: String?
	let puref: String
	let shortName: String
	let surName: String?
	
	internal init(countryCode: String, countryName: String, date: Date, firstName: String?, middleName: String?, paymentDate: String, phoneNumber: String?, puref: String, shortName: String, surName: String?, type: Kind) {
		
		self.countryCode = countryCode
		self.countryName = countryName
		self.firstName = firstName
		self.middleName = middleName
		self.phoneNumber = phoneNumber
		self.puref = puref
		self.shortName = shortName
		self.surName = surName
		super.init(date: date, paymentDate: paymentDate, type: type)
	}

	private enum CodingKeys: String, CodingKey {
		case countryCode, countryName, firstName, middleName, phoneNumber, puref, shortName, surName
	}
	
	required init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		countryCode = try container.decode(String.self, forKey: .countryCode)
		countryName = try container.decode(String.self, forKey: .countryName)
		firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
		middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
		phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
		puref = try container.decode(String.self, forKey: .puref)
		shortName = try container.decode(String.self, forKey: .shortName)
		surName = try container.decodeIfPresent(String.self, forKey: .surName)
		try super.init(from: decoder)
	}
}
