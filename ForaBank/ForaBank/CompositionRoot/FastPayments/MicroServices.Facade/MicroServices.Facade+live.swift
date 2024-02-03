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
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> Self {
        
        let createContract = NanoServices.makeFPSCreateContract(httpClient, log)
        let getBankDefault = NanoServices.makeDecoratedGetBankDefault(httpClient, log)
        let getContract = NanoServices.makeFPSGetContract(httpClient, log)
        let getConsent = NanoServices.makeFPSGetConsent(httpClient, log)
        let updateContract = NanoServices.makeFPSUpdateContract(httpClient, log)
        
        return .init(
            createFastContract: createContract,
            getBankDefaultResponse: getBankDefault,
            getClientConsent: getConsent,
            getFastContract: getContract,
            getProducts: getProducts,
            getBanks: getBanks,
            updateFastContract: updateContract
        )
    }
}
