//
//  GetSberQRDataResult+emptySuccess.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.12.2023.
//

@testable import Vortex
import Foundation
import SberQR

func anyGetSberQRDataResponse(
    qrcID: String = UUID().uuidString
) -> GetSberQRDataResponse {
    
    .empty(qrcID: qrcID)
}
