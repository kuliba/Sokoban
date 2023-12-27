//
//  Services+makeFastPaymentsServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
import Tagged

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
            }
        )
    }
}

extension Array where Element == FastPaymentContractFullInfoType {
    
    var fpsCFLResponse: FastPaymentsServices.FPSCFLResponse {
        
        guard let first else { return .missing }
        guard let phone else { return .error}
        
        if first.hasTripleYes { return .active(phone) }
        if first.hasTripleNo { return .inactive }
        
        return .error
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
