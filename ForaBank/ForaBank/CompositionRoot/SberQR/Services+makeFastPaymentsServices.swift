//
//  Services+makeFastPaymentsServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine

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
        
        guard first.hasTripleYes else { return .inactive }
        
        return .active
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
}
