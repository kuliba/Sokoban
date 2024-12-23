//
//  RemoteServices.ResponseMapper.LatestPayment+paymentPayload.swift
//  
//
//  Created by Igor Malyarov on 22.12.2024.
//

import Foundation
import RemoteServices

extension RemoteServices.ResponseMapper.LatestPayment {
    
    public var paymentPayload: PaymentPayload? {
        
        switch self {
        case let .service(service):
            guard let paymentFlow = service.paymentFlow
            else { return nil }
            
            return service.payload.map { .paymentFlow(paymentFlow, $0) }
            
        case let .withPhone(withPhone):
            switch withPhone.type {
            case .phone:
                return withPhone.phonePayload.map { .phone($0) }
                
            default:
                return nil
            }
        }
    }
    
    public enum PaymentPayload: Equatable {
        
        case paymentFlow(PaymentFlow, Payload)
        case phone(PhonePayload)
        
        public struct Payload: Equatable {
            
            public let amount: Decimal
            public let puref: String
            public let fields: [Field]
            
            public init(
                amount: Decimal, 
                puref: String,
                fields: [Field]
            ) {
                self.amount = amount
                self.puref = puref
                self.fields = fields
            }
            
            public struct Field: Equatable {
                
                public let id: String     // fieldName
                public let title: String? // fieldTitle
                public let svg: String?   // svgImage
                public let value: String  // fieldValue
                
                public init(
                    id: String, 
                    title: String?,
                    svg: String?,
                    value: String
                ) {
                    self.id = id
                    self.title = title
                    self.svg = svg
                    self.value = value
                }
            }
        }
        
        public struct PhonePayload: Equatable {
            
            public let amount: Decimal
            public let bankID: String
            public let phoneNumber: String
            public let puref: String?
            
            public init(
                amount: Decimal, 
                bankID: String,
                phoneNumber: String,
                puref: String?
            ) {
                self.amount = amount
                self.bankID = bankID
                self.phoneNumber = phoneNumber
                self.puref = puref
            }
        }
    }
}

private typealias LatestPayment = RemoteServices.ResponseMapper.LatestPayment

private extension LatestPayment.Service {
    
    var payload: LatestPayment.PaymentPayload.Payload? {
        
        guard paymentFlow != .qr,
              let amount
        else { return nil }
        
        return .init(
            amount: amount,
            puref: puref,
            fields: additionalItems?.map(\.field)  ?? []
        )
    }
}

private extension LatestPayment.Service.AdditionalItem {
    
    var field: LatestPayment.PaymentPayload.Payload.Field {
        
        return .init(id: fieldName, title: fieldTitle, svg: svgImage, value: fieldValue)
    }
}

private extension LatestPayment.WithPhone {
    
    var phonePayload: LatestPayment.PaymentPayload.PhonePayload? {
        
        guard let amount, let bankID, let phoneNumber else { return nil }
        
        return .init(
            amount: amount,
            bankID: bankID,
            phoneNumber: phoneNumber,
            puref: puref
        )
    }
}
