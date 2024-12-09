//
//  MakeTransferResponse.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation

struct MakeTransfer: Decodable {
    
    let paymentOperationDetailId: Int
    let documentStatus: String
    let productOrderingResponseMessage: String
}
