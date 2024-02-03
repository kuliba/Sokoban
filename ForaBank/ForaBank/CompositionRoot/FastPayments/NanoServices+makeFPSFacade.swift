//
//  NanoServices+makeFPSFacade.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings

extension NanoServices {
    
    typealias FPSFacade = MicroServices.Facade
    
    static func makeFPSFacade(
        _ httpClient: HTTPClient,
        getProducts: @escaping FPSFacade.GetProducts,
        getBanks: @escaping FPSFacade.GetBanks,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> FPSFacade {
        
        let createContract = makeFPSCreateContract(httpClient, log)
        let getBankDefault = makeDecoratedGetBankDefault(httpClient, log)
        let getContract = makeFPSGetContract(httpClient, log)
        let getConsent = makeFPSGetConsent(httpClient, log)
        let updateContract = makeFPSUpdateContract(httpClient, log)

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
