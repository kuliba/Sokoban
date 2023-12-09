//
//  GetSberQRDataResult+emptySuccess.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.12.2023.
//

@testable import ForaBank
import Foundation
import SberQR

extension GetSberQRDataResult {
    
    static let emptySuccess: Self = .success(anyGetSberQRDataResponse())
}

func anyGetSberQRDataResponse(
    qrcID: String = UUID().uuidString
) -> GetSberQRDataResponse {
    
    .init(
        qrcID: qrcID,
        parameters: [],
        required: []
    )
}
