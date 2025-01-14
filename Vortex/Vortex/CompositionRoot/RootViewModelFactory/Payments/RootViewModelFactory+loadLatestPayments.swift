//
//  RootViewModelFactory+loadLatestPayments.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.12.2024.
//

import RemoteServices
import SwiftUI

extension RootViewModelFactory {
    
    @inlinable
    func loadLatestPayments(
        for latestPaymentsCategories: [String],
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        let getLatestPayments = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetAllLatestPaymentsV3Request,
            mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestPaymentsResponse
        )
        
        getLatestPayments(latestPaymentsCategories) { [weak self] in
            
            guard let self else { return }
            
            completion($0.map { $0.map { .init(origin: $0, avatar: self.avatar(origin: $0)) } })
            _ = getLatestPayments
        }
    }
    
    @inlinable
    func avatar(
        origin: LatestOrigin
    ) -> Latest.Avatar {
        
        return .init(fullName: fullName(origin: origin) ?? "", image: nil, topIcon: topIcon(origin: origin), icon: icon(origin: origin))
    }
    
    @inlinable
    func icon(
        origin: LatestOrigin
    ) -> LatestPaymentsView.ViewModel.LatestPaymentButtonVM.Avatar? {
        
        guard let phoneNumber = origin.phoneNumber, let contact = getContact(for: phoneNumber)
        else { return nil }
                        
        if let avatar = contact.avatar, let avatarImg = Image(data: avatar.data) {
            
            return .image(avatarImg)
            
        } else if let initials = contact.initials {
            
            return .text(initials)
        }
        
        return nil
    }
    
    @inlinable
    func topIcon(
        origin: LatestOrigin
    ) -> Image? {
        
        switch origin {
        case let .service(service):
            switch service.type {
            case "outside":
                guard let countryId = service.additionalItems?.country,
                      let country = model.countriesList.value.first(where: { $0.id == countryId } ),
                      let image = country.svgImage?.image 
                else { return nil }
                
                return image
                
            default: return nil
            }
            
        case let .withPhone(withPhone):
            switch withPhone.type {
            case "phone":
                guard let bankID = withPhone.bankID else { return nil }
                
                return model.dictionaryBank(for: bankID)?.svgImage.image
                            
            case "mobile":
                
                guard let puref = withPhone.puref else { return nil }
                
                return model.dictionaryAnywayOperator(for: puref)?
                    .logotypeList.first?.svgImage?.image
                
            default:
                return nil
            }
        }
    }
    
    @inlinable
    func fullName(
        origin: LatestOrigin
    ) -> String? {
        
        if let phoneNumber = origin.phoneNumber {
            
            return getContact(for: phoneNumber)?.fullName ?? format(phoneNumber: phoneNumber.addCodeRuIfNeeded())
        } else {
            
            switch origin {
            case let .service(service):     return service.name ?? service.lpName ?? ""
            case let .withPhone(withPhone): return withPhone.name ?? ""
            }
        }
    }
    
    @inlinable
    func getContact(
        for phoneNumber: String
    ) -> AddressBookContact? {
        
        guard case .available = model.contactsPermissionStatus else { return nil }
        
        let phoneNumbers = [
            phoneNumber.addCodeRuIfNeeded(),
            phoneNumber.add8IfNeeded(),
            phoneNumber.replace7To8IfNeeded(),
            format(phoneNumber: phoneNumber)
        ]

        for phoneNumber in phoneNumbers {
            
            if let contact = model.contact(for: phoneNumber) {
                return contact
            }
        }
        return nil
    }
    
    @inlinable
    func format(phoneNumber: String) -> String {
        
        let phoneFormatter = PhoneNumberKitFormater()
        return phoneFormatter.format(phoneNumber)
    }
    
    @inlinable
    func loadLatestPayments(
        for latestPaymentsCategories: [String],
        completion: @escaping ([Latest]?) -> Void
    ) {
        loadLatestPayments(for: latestPaymentsCategories) {
            
            completion((try? $0.get()) ?? [])
        }
    }
    
    @inlinable
    func loadLatestPayments(
        for latestPaymentsCategory: String?,
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        loadLatestPayments(for: [latestPaymentsCategory].compactMap { $0 }, completion: completion)
    }
    
    @inlinable
    func loadLatestPayments(
        for category: ServiceCategory,
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        loadLatestPayments(for: category.latestPaymentsCategory, completion: completion)
    }
}

private extension Array where Element == LatestOrigin.Service.AdditionalItem {
    
    var country: String? {
        
        for item in self {
            
            if item.fieldName == "trnPickupPoint" {
                return item.fieldValue
            }
        }
        return nil
    }
    
    var phoneNumber: String? {
        
        for item in self {
            
            if item.fieldName == "a3_NUMBER_1_2" {
                return item.fieldValue
            }
        }
        return nil
    }
}

private extension LatestOrigin {
    
    var phoneNumber: String? {
       
        switch self {
        case let .service(service):
            return service.additionalItems?.phoneNumber
            
        case let .withPhone(withPhone):
            return withPhone.phoneNumber
        }
    }
}
