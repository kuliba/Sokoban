//
//  QRPaymentType.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

struct QRPaymentType: Equatable, Codable {
    
    let content: String
    let paymentType: String
}
