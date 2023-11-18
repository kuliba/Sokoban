//
//  MakeTransferResponse.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation

struct MakeTransferResponse: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: Data

    struct Data: Decodable {
        
        let paymentOperationDetailId: Int
        let documentStatus: String
        let productOrderingResponseMessage: String
    }
}
