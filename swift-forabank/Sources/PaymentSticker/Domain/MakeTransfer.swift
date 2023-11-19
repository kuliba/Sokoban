//
//  MakeTransfer.swift
//  
//
//  Created by Дмитрий Савушкин on 19.11.2023.
//

import Foundation

public enum MakeTransferError: Error , Equatable {
    
    case error(
        statusCode: Int,
        errorMessage: String
    )
    case invalidData(statusCode: Int, data: Data)
}

public struct MakeTransfer: Decodable {
    
    let paymentOperationDetailId: Int
    let documentStatus: String
    let productOrderingResponseMessage: String
}
