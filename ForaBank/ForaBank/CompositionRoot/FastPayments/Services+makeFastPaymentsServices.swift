//
//  Services+makeFastPaymentsServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
import Foundation
import Tagged

// stubs: b: 1-4 | c: 1-5
private extension FastPaymentsServices.GetDefaultAndConsentResult {
    
    static let b1c1: Self = .success(.init(
        consentList: [],
        defaultForaBank: true
    ))
}

extension Services {
    
    static func makeFastPaymentsServices(
        httpClient: HTTPClient,
        model: Model,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> FastPaymentsServices {
        
        .init(
            getFastPaymentContractFindList: {
                
                let request = ModelAction.FastPaymentSettings.ContractFindList.Request()
                model.action.send(request)
             
                return model.fastPaymentContractFullInfo
                    .map(\.fpsCFLResponse)
                    .eraseToAnyPublisher()
            },
            getDefaultAndConsent: { phone, completion in
            
                // completion(.failure(NSError(domain: "GetDefaultAndConsent Error", code: -1)))
                completion(.b1c1)
            }
        )
    }
}

extension Array where Element == FastPaymentContractFullInfoType {
    
    var fpsCFLResponse: FastPaymentsServices.FPSCFLResponse {
        
        guard let first else { return .noContract }
        #warning("replacing `FastPaymentContractFullInfoType` with Result would allow to have a berr way to construct error case")
        guard let phone else { return .fixedError }
        
        if first.hasTripleYes { return .contract(.init(phone: phone, status: .active)) }
        if first.hasTripleNo { return .contract(.init(phone: phone, status: .inactive)) }
        
        return .fixedError
    }
    
    private var phone: FastPaymentsServices.Phone? {
        
        guard
            let list = first?.fastPaymentContractAttributeList,
            let phoneNumber = list.first?.phoneNumber,
            !phoneNumber.isEmpty
        else { return nil }
        
        return .init(phoneNumber)
    }
}

extension FastPaymentsServices.FPSCFLResponse {
    
    static let fixedError: Self = .error("Превышено время ожидания.\nПопробуйте позже.")
}

private extension FastPaymentContractFullInfoType {
    
    var hasTripleYes: Bool {
        
        guard let accountAttributeList = fastPaymentContractAccountAttributeList?.first,
              let contractAttributeList = fastPaymentContractAttributeList?.first
        else { return false }
        
        return accountAttributeList.flagPossibAddAccount == .yes
        && contractAttributeList.flagClientAgreementIn == .yes
        && contractAttributeList.flagClientAgreementOut == .yes
    }
    
    var hasTripleNo: Bool {
        
        guard let accountAttributeList = fastPaymentContractAccountAttributeList?.first,
              let contractAttributeList = fastPaymentContractAttributeList?.first
        else { return false }
        
        return accountAttributeList.flagPossibAddAccount == .no
        && contractAttributeList.flagClientAgreementIn == .no
        && contractAttributeList.flagClientAgreementOut == .no
    }
}
