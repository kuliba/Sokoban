//
//  InfoRepeatPaymentServices.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 06.08.2024.
//

import Foundation
import RemoteServices
import GetInfoRepeatPaymentService
import GenericRemoteService

struct InfoRepeatPaymentServices {
    
    typealias CreateInfoRepeatPayment = (InfoForRepeatPaymentPayload, @escaping GetInfoRepeatPaymentDomain.Completion) -> Void
    typealias GetInfoPaymentResult = Result<GetInfoRepeatPaymentDomain.GetInfoRepeatPayment, MappingError>
    typealias GetInfoPaymentCompletion = (GetInfoPaymentResult) -> Void
    typealias GetInfoPaymentData = (URL, @escaping GetInfoPaymentCompletion) -> Void
    typealias MappingError = MappingRemoteServiceError<GetInfoRepeatPaymentDomain.InfoPaymentError>

    let createInfoRepeatPaymentServices: (InfoForRepeatPaymentPayload, @escaping (Result<GetInfoRepeatPaymentDomain.GetInfoRepeatPayment, RemoteServiceError<Error, Error, GetInfoRepeatPaymentDomain.InfoPaymentError>>) -> Void) -> ()
}

// MARK: - Preview Content

extension InfoRepeatPaymentServices {
    
    static func preview() -> Self {
        
        .init(createInfoRepeatPaymentServices: { _, completion in
            
            completion(.success(.init(
                type: .betweenTheir,
                parameterList: [],
                productTemplate: nil
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
