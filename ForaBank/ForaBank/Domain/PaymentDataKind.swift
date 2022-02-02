//
//  PaymentDataKind.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/27/22.
//

import Foundation

enum PaymentDataKind: String, Codable {

	case phone
	case country
	case service
	case mobile
	case internet
	case transport
}
