//
//  MicroServices.Facade+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings

extension MicroServices.Facade {
    
    static func live(
        _ httpClient: HTTPClient,
        _ getProducts: @escaping GetProducts,
        _ getBanks: @escaping GetBanks,
        _ getBankDefaultResponse: @escaping GetBankDefaultResponse,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> Self {
        
        let createContract = NanoServices.makeFPSCreateContract(httpClient, log)
        let getContract = NanoServices.makeFPSGetContract(httpClient, log)
        let getConsent = NanoServices.makeFPSGetConsent(httpClient, log)
        let updateContract = NanoServices.makeFPSUpdateContract(httpClient, log)
        
        return .init(
            createFastContractFetch: createContract,
            getBankDefaultResponse: getBankDefaultResponse,
            getClientConsentFetch: getConsent,
            getFastContractFetch: getContract,
            getProducts: getProducts,
            getBanks: getBanks,
            updateFastContractFetch: updateContract
        )
    }
}
