//
//  OperationPickerContent.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Foundation
import RemoteServices

typealias LatestOrigin = RemoteServices.ResponseMapper.LatestPayment

struct Latest: Equatable {
    
    let origin: LatestOrigin
    // let name: String or label: LatestPaymentButtonLabel
}

extension Latest {
    
    var amount: Decimal? {
        
        switch origin {
        case let .service(service):
            return service.amount
            
        case let .withPhone(withPhone):
            return withPhone.amount
        }
    }
    
    var md5Hash: String? {
        
        switch origin {
        case let .service(service):
            return service.md5Hash
            
        case let .withPhone(withPhone):
            return withPhone.md5Hash
        }
    }
    
    var name: String {
        
        switch origin {
        case let .service(service):
            return service.name ?? String(describing: service)
            
        case let .withPhone(withPhone):
            return withPhone.name ?? withPhone.phoneNumber
        }
    }

    var puref: String {
        
        switch origin {
        case let .service(service):
            return service.puref
            
        case let .withPhone(withPhone):
            return withPhone.puref
        }
    }
    
    var type: String {
        
        switch origin {
        case let .service(service):
            return service.type.rawValue
            
        case let .withPhone(withPhone):
            return withPhone.type.rawValue
        }
    }
}
