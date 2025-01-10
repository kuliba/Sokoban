//
//  Latest.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Foundation
import RemoteServices
import SwiftUI

typealias LatestOrigin = RemoteServices.ResponseMapper.LatestPayment

struct Latest: Equatable {
    
    private let origin: LatestOrigin
    // let name: String or label: LatestPaymentButtonLabel
    private let avatar: Avatar
    
    init(
        origin: LatestOrigin,
        avatar: Avatar
    ) {
     
        self.origin = origin
        self.avatar = avatar
    }
    
    struct Avatar: Equatable {
        
        let fullName: String
        let image: Image?
        let topIcon: Image?
    }
}

extension Latest {
    
    func updating(
        with image: Image
    ) -> Self {
        
        return .init(origin: origin, avatar: .init(fullName: avatar.fullName, image: image, topIcon: avatar.topIcon))
    }
    
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
                        
            return withPhone.name ?? avatar.fullName
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
            return .init(
                amount: "",
                avatar: .image(avatar.image ?? .ic24MoreHorizontal),
                description: avatar.fullName,
                topIcon: avatar.topIcon
            )

        case let .withPhone(withPhone):
            
            let image: LatestPaymentsView.ViewModel.LatestPaymentButtonVM.Avatar = {
                
                if let image = avatar.image {
                    return .image(image)
                }
                return .icon(.ic24Smartphone, .iconGray)
            }()

            return .init(
                amount: "",
                avatar: image,
                description: avatar.fullName,
                topIcon: avatar.topIcon
            )
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
