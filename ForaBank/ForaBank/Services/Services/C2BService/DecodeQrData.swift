//
//  DecodableQrData.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.09.2023.
//

import Foundation

struct DecodableQrData: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: QRScenarioData?
}
