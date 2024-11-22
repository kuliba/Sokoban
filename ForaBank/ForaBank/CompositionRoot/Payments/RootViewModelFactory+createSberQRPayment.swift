//
//  RootViewModelFactory+createSberQRPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation
import SberQR

extension RootViewModelFactory {
    
    func createSberQRPayment(
        payload: (URL, SberQRConfirmPaymentState),
        completion: @escaping (Result<CreateSberQRPaymentResponse, QRNavigation.ErrorMessage>) -> Void
    ){
        let createPayment = nanoServiceComposer.compose(
            createRequest: RequestFactory.createCreateSberQRPaymentRequest,
            mapResponse: SberQR.ResponseMapper.mapCreateSberQRPaymentResponse
        )
        
        guard let payload = payload.1.makePayload(with: payload.0)
        else { return completion(.failure(.techError)) }
        
        createPayment(payload) {
            
            completion($0.mapError { _ in .techError })
            _ = createPayment
        }
    }
}
