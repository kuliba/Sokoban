//
//  Services+makeFPSFacade.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings

extension Services {
    
    static func makeFPSFacade(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> MicroServices.Facade {
        
        let getContract = NanoServices.makeFPSGetContract(
            httpClient: httpClient,
            log: log
        )
        
        return .init(
            createContract: unimplemented(),
            getBankDefault: unimplemented(),
            getConsent: unimplemented(),
            getContract: getContract,
            getProducts: unimplemented(),
            updateContract: unimplemented()
        )
    }
}
