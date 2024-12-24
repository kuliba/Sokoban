//
//  GetInfoRepeatPaymentDomain+ext.swift
//  Vortex
//
//  Created by Andryusina Nataly on 22.12.2024.
//

import Foundation
import GetInfoRepeatPaymentService
import RemoteServices

extension GetInfoRepeatPaymentDomain {
    
    typealias MappingError = RemoteServices.ResponseMapper.MappingError
    typealias Response = GetInfoRepeatPayment
    typealias Result = RemoteServices.ResponseMapper.MappingResult<Response>
    typealias Completion = (Result) -> Void
}

extension String {
    
    var paymentType: PaymentType? {
        .init(self)
    }
}
