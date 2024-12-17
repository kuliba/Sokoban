//
//  PaymentPhoneData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

struct PaymentPhoneData: Codable, Equatable, Hashable, Identifiable {

    var id: Int { hashValue }
	let bankId: String
	let bankName: String
	let payment: Bool
    let defaultBank: Bool
}
