//
//  Latest.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Foundation
import RemoteServices

typealias LatestOrigin = RemoteServices.ResponseMapper.LatestPayment

struct Latest: Equatable {
    
    private let origin: LatestOrigin
    // let name: String or label: LatestPaymentButtonLabel
    
    init(origin: LatestOrigin) {
     
        self.origin = origin
    }
}

extension Latest {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment { origin.latest }
    
    var amount: Decimal? {
        
        switch origin {
        case let .service(service):
            return service.amount
            
        case let .withPhone(withPhone):
            return withPhone.amount
        }
    }
    
    var id: Int {
        
        switch origin {
        case let .service(service):     return service.date
        case let .withPhone(withPhone): return withPhone.date
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

extension UtilityPaymentLastPayment {
    
    init(_ latest: Latest) {
        
        self.init(
            date: .init(),
            amount: latest.amount ?? 0,
            name: latest.name,
            md5Hash: latest.md5Hash,
            puref: latest.puref,
            type: latest.type,
            additionalItems: latest.additionalItems
        )
    }
}

extension Latest {
    
    var additionalItems: [UtilityPaymentLastPayment.AdditionalItem] {
        
        switch origin {
        case let .service(service):
            return (service.additionalItems ?? []).map {
                
                return .init(
                    fieldName: $0.fieldName,
                    fieldValue: $0.fieldValue,
                    fieldTitle: $0.fieldTitle,
                    svgImage: $0.svgImage
                )
            }
            
        case .withPhone:
            return []
        }
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment {
        
        switch self {
        case let .service(service):
            return service.latest
            
        case let .withPhone(withPhone):
            return withPhone.latest
        }
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment {
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, puref: puref, type: type.rawValue, additionalItems: additionalItems?.map(\.additional) ?? [])
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service.AdditionalItem {
    
    var additional: RemoteServices.ResponseMapper.LatestServicePayment.AdditionalItem {
        
        return .init(fieldName: fieldName, fieldValue: fieldValue, fieldTitle: fieldTitle, svgImage: svgImage)
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.WithPhone {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment {
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, puref: puref, type: type.rawValue, additionalItems: [])
    }
}

extension Latest {
    
    var label: LatestPaymentButtonLabel {
        
        switch origin {
        case let .service(service):
            return service.label
            
        case let .withPhone(withPhone):
            return withPhone.label
        }
    }
}

// LatestPaymentsViewComponent.swift:204

private extension RemoteServices.ResponseMapper.LatestPayment.Service {
    
    var label: LatestPaymentButtonLabel {
        
        return .init(
            amount: amount.map(String.init),
            avatar: .text(name ?? lpName ?? ""),
            description: "",
            topIcon: nil
        )
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.WithPhone {
    
    var label: LatestPaymentButtonLabel {
        
        return .init(
            amount: amount.map(String.init),
            avatar: .text(name ?? ""),
            description: "",
            topIcon: nil
        )
    }
}
