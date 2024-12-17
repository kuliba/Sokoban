//
//  GetSberQRDataResult+emptySuccess.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.12.2023.
//

@testable import ForaBank
import Foundation
import SberQR

func anyGetSberQRDataResponse(
    qrcID: String = UUID().uuidString
) -> GetSberQRDataResponse {
    
    .empty(qrcID: qrcID)
}
