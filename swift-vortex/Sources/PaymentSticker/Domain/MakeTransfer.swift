//
//  MakeTransfer.swift
//  
//
//  Created by Дмитрий Савушкин on 19.11.2023.
//

import Foundation

public enum MakeTransferError: Error , Equatable {
    
    case network
    case error(
        statusCode: Int,
        errorMessage: String
    )
    case invalidData(statusCode: Int, data: Data)
}

public struct MakeTransferResponse: Decodable {
    
    let paymentOperationDetailId: Int
    let documentStatus: String
    let productOrderingResponseMessage: String
    
    public init(
        paymentOperationDetailId: Int,
        documentStatus: String,
        productOrderingResponseMessage: String
    ) {
        self.paymentOperationDetailId = paymentOperationDetailId
        self.documentStatus = documentStatus
        self.productOrderingResponseMessage = productOrderingResponseMessage
    }
}
