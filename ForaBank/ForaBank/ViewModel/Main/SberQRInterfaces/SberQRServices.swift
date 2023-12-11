//
//  SberQRServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import Foundation
import SberQR

struct SberQRServices {
    
    typealias CreateSberQRPayment = (CreateSberQRPaymentPayload, @escaping CreateSberQRPaymentCompletion) -> Void
    
    typealias GetSberQRDataResult = Result<GetSberQRDataResponse, MappingRemoteServiceError<MappingError>>
    typealias GetSberQRDataCompletion = (GetSberQRDataResult) -> Void
    typealias GetSberQRData = (URL, @escaping GetSberQRDataCompletion) -> Void

    let createSberQRPayment: CreateSberQRPayment
    let getSberQRData: GetSberQRData
}

// MARK: - Preview Content

extension SberQRServices {
    
    static func empty() -> Self {
    
        .preview(
            createSberQRPaymentStub: .success(.empty()),
            getSberQRDataStub: .success(.empty())
        )
    }
    
    static func preview(
        createSberQRPaymentStub: CreateSberQRPaymentResult,
        getSberQRDataStub: GetSberQRDataResult
    ) -> Self {
        
        .init(
            createSberQRPayment: { _, completion in
                
                completion(createSberQRPaymentStub)
            },
            getSberQRData: { _, completion in
                
                completion(getSberQRDataStub)
            }
        )
    }
}

extension CreateSberQRPaymentResponse {
    
    static func empty() -> Self {
        
        .init(parameters: [])
    }
}

extension GetSberQRDataResponse {
    
    static func empty(
        qrcID: String = UUID().uuidString
    ) -> Self {
        
        .init(
            qrcID: UUID().uuidString,
            parameters: [],
            required: []
        )
    }
}
