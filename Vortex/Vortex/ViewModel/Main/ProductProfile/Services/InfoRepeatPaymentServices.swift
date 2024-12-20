//
//  InfoRepeatPaymentServices.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 06.08.2024.
//

import Foundation
import RemoteServices
import GetInfoRepeatPaymentService
import GenericRemoteService

struct InfoRepeatPaymentServices {
    
    typealias Payload = InfoForRepeatPaymentPayload
    typealias GetInfoRepeatPaymentCompletion = (Result<GetInfoRepeatPaymentDomain.Response, Error>) -> Void
    typealias CreateInfoRepeatPayment = (Payload, @escaping GetInfoRepeatPaymentCompletion) -> Void
    
    let createInfoRepeatPaymentServices: CreateInfoRepeatPayment
}

// MARK: - Preview Content

extension InfoRepeatPaymentServices {
    
    static func preview() -> Self {
        
        .init(createInfoRepeatPaymentServices: { _, completion in
            
            completion(.success(.init(
                type: .betweenTheir,
                parameterList: [],
                productTemplate: nil, 
                paymentFlow: nil
            )))
        })
    }
    
    static func preview(
        getInfoRepeatPaymentDomain: GetInfoRepeatPaymentDomain.Result
    ) -> Self {
        
        .init(
            createInfoRepeatPaymentServices: { _, completion in
            
//                completion(getInfoRepeatPaymentDomain)
            }
        )
    }
}
