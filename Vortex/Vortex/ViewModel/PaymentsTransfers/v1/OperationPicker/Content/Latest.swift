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
        let icon: LatestPaymentsView.ViewModel.LatestPaymentButtonVM.Avatar?
    }
}

extension Latest {
    
    func updating(
        with image: Image
    ) -> Self {
        
        return .init(origin: origin, avatar: .init(fullName: avatar.fullName, image: origin.latest.type == "mobile" ? avatar.image : image, topIcon: origin.latest.type == "mobile" ? image : avatar.topIcon, icon: avatar.icon))
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
    
    typealias PaymentFlow = LatestOrigin.PaymentFlow
    
    var puref: String {
        
        switch origin {
        case let .service(service):
            return service.puref
            
        case let .withPhone(withPhone):
            return withPhone.puref ?? ""
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
    
    var flow: String? {
        
        switch origin {
        case let .service(service):
            return service.flow
            
        case let .withPhone(withPhone):
            return withPhone.flow
        }
    }
}

private extension LatestOrigin.PaymentFlow {
    
    var flow: String? {
        switch self {
        case .mobile:               return "mobile"
        case .qr:                   return "qr"
        case .standard:             return "standard"
        case .taxAndStateServices:  return "taxAndStateServices"
        case .transport:            return "transport"
        }
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service {
    
    var flow: String? { paymentFlow?.flow }
}

private extension RemoteServices.ResponseMapper.LatestPayment.WithPhone {
    
    var flow: String? { paymentFlow?.flow }
}

extension UtilityPaymentLastPayment {
    
    init(_ latest: Latest) {
        
        self.init(
            date: .init(),
            amount: latest.amount ?? 0,
            name: latest.name,
            md5Hash: latest.md5Hash,
            paymentFlow: latest.flow,
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
            
        case let .withPhone(withPhone):
            
            return [
                .init(fieldName: withPhone.detail == .sfp ? "RecipientID" : "a3_NUMBER_1_2", fieldValue: withPhone.phoneNumber, fieldTitle: nil, svgImage: nil),
                .init(fieldName: withPhone.detail == .sfp ? "BankRecipientID" : "", fieldValue: withPhone.bankID ?? "", fieldTitle: nil, svgImage: nil)
            ]
        }
    }
    
    var phoneNumber: String? {
        
        switch origin {
        case .service:
            return nil
            
        case let .withPhone(withPhone):
            return withPhone.phoneNumber
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
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, paymentFlow: flow, puref: puref, type: type.rawValue, additionalItems: additionalItems?.map(\.additional) ?? [])
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service.AdditionalItem {
    
    var additional: RemoteServices.ResponseMapper.LatestServicePayment.AdditionalItem {
        
        return .init(fieldName: fieldName, fieldValue: fieldValue, fieldTitle: fieldTitle, svgImage: svgImage)
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.WithPhone {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment {
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, paymentFlow: flow, puref: puref ?? "", type: type.rawValue, additionalItems: [])
    }
}

extension Latest {
    
    var label: LatestPaymentButtonLabel {
        
        return .init(
            amount: "",
            avatar: avatarImage,
            description: avatar.fullName,
            topIcon: avatar.topIcon
        )
    }
    
    var avatarImage: LatestPaymentsView.ViewModel.LatestPaymentButtonVM.Avatar {
        
        if let image = avatar.icon {
            return image
        }
        if let image = avatar.image {
            return .image(image)
        }

        switch origin {
        case .service:
            return .icon(.ic24MoreHorizontal, .iconGray)
            
        case .withPhone:
            return .icon(.ic24Smartphone, .iconGray)
        }
    }
}
