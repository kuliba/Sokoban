//
//  MicroServices.Facade+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import Foundation

extension MicroServices.Facade {
    
    static func live(
        _ httpClient: HTTPClient,
        _ getProducts: @escaping GetProducts,
        _ getBanks: @escaping GetBanks,
        _ getBankDefaultResponse: @escaping GetBankDefaultResponse,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> Self {
        
        let createContract = adaptedLoggingFetch(
            ForaRequestFactory.createCreateFastPaymentContractRequest,
            FastResponseMapper.mapCreateFastPaymentContractResponse
        )
        
        let getContract = adaptedLoggingFetch(
            ForaRequestFactory.createFastPaymentContractFindListRequest,
            FastResponseMapper.mapFastPaymentContractFindListResponse
        )
        
        let getConsent = adaptedLoggingFetch(
            ForaRequestFactory.createGetClientConsentMe2MePullRequest,
            FastResponseMapper.mapGetClientConsentMe2MePullResponse
        )
        
        let updateContract = adaptedLoggingFetch(
            ForaRequestFactory.createUpdateFastPaymentContractRequest,
            FastResponseMapper.mapUpdateFastPaymentContractResponse
        )
        
        return .init(
            createFastContractFetch: { createContract(.create($0), $1) },
            getBankDefaultResponse: getBankDefaultResponse,
            getClientConsentFetch: getConsent,
            getFastContractFetch: getContract,
            getProducts: getProducts,
            getBanks: getBanks,
            updateFastContractFetch: { updateContract(.create($0), $1) }
        )
        
        typealias ForaRequestFactory = ForaBank.RequestFactory
        typealias FastResponseMapper = FastPaymentsSettings.ResponseMapper
        
        func adaptedLoggingFetch<Output>(
            _ createRequest: @escaping () throws -> URLRequest,
            _ mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Output, MappingError>,
            file: StaticString = #file,
            line: UInt = #line
        ) -> NanoServices.VoidFetch<Output> {
            
            NanoServices.adaptedLoggingFetch(
                createRequest: createRequest,
                httpClient: httpClient,
                mapResponse: mapResponse,
                log: log,
                file: file,
                line: line
            )
        }
        
        func adaptedLoggingFetch<Input, Output>(
            _ createRequest: @escaping (Input) throws -> URLRequest,
            _ mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Output, MappingError>,
            file: StaticString = #file,
            line: UInt = #line
        ) -> NanoServices.Fetch<Input, Output> {
            
            NanoServices.adaptedLoggingFetch(
                createRequest: createRequest,
                httpClient: httpClient,
                mapResponse: mapResponse,
                log: log,
                file: file,
                line: line
            )
        }
    }
}

private extension FastPaymentsSettings.RequestFactory.CreateFastPaymentContractPayload {
    
    static func create(
        _ productID: FastPaymentsSettings.Product.ID
    ) -> Self {
        
        .init(
            accountID: productID.rawValue,
            flagBankDefault: .empty,
            flagClientAgreementIn: .yes,
            flagClientAgreementOut: .yes
        )
    }
}

private extension FastPaymentsSettings.RequestFactory.UpdateFastPaymentContractPayload {
    
    static func create(
        _ payload: MicroServices.Facade.ContractUpdatePayload
    ) -> Self {
        
        switch payload.target {
        case .active:
            return .init(
                contractID: payload.contractID.rawValue,
                accountID: payload.accountID.rawValue,
                flagBankDefault: .empty,
                flagClientAgreementIn: .yes,
                flagClientAgreementOut: .yes
            )
            
        case .inactive:
            return .init(
                contractID: payload.contractID.rawValue,
                accountID: payload.accountID.rawValue,
                flagBankDefault: .empty,
                flagClientAgreementIn: .no,
                flagClientAgreementOut: .no
            )
        }
    }
}
