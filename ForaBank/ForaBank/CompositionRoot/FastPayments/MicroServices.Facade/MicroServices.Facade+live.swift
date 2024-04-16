//
//  MicroServices.Facade+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import Foundation
import GenericRemoteService
import RemoteServices

extension MicroServices.Facade {
    
    convenience init(
        _ httpClient: HTTPClient,
        _ getProducts: @escaping GetProducts,
        _ getBanks: @escaping GetBanks,
        _ getBankDefaultResponse: @escaping GetBankDefaultResponse,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) {
        let createContract = adaptedLoggingFetch(
            mapPayload: { .create($0) },
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
            mapPayload: { .create($0) },
            ForaRequestFactory.createUpdateFastPaymentContractRequest,
            FastResponseMapper.mapUpdateFastPaymentContractResponse
        )
        
        self.init(
            createFastContractFetch: createContract,
            getBankDefaultResponse: getBankDefaultResponse,
            getClientConsentFetch: getConsent,
            getFastContractFetch: getContract,
            getProducts: getProducts,
            getBanks: getBanks,
            updateFastContractFetch: updateContract
        )
        
        typealias ForaRequestFactory = ForaBank.RequestFactory
        typealias FastResponseMapper = RemoteServices.ResponseMapper
        typealias MapResponse<T> = (Data, HTTPURLResponse) -> Result<T, RemoteServices.ResponseMapper.MappingError>
        
        func adaptedLoggingFetch<Payload, Input, Output>(
            mapPayload: @escaping (Payload) -> Input,
            _ createRequest: @escaping (Input) throws -> URLRequest,
            _ mapResponse: @escaping MapResponse<Output>,
            file: StaticString = #file,
            line: UInt = #line
        ) -> NanoServices.Fetch<Payload, Output, ServiceFailure> {
            
            NanoServices.adaptedLoggingFetch(
                createRequest: { try createRequest(mapPayload($0)) },
                httpClient: httpClient,
                mapResponse: mapResponse,
                mapError: ServiceFailure.init(error:),
                log: log,
                file: file,
                line: line
            )
        }
        
        func adaptedLoggingFetch<Output>(
            _ createRequest: @escaping () throws -> URLRequest,
            _ mapResponse: @escaping MapResponse<Output>,
            file: StaticString = #file,
            line: UInt = #line
        ) -> NanoServices.VoidFetch<Output, ServiceFailure> {
            
            NanoServices.adaptedLoggingFetch(
                createRequest: createRequest,
                httpClient: httpClient,
                mapResponse: mapResponse,
                mapError: ServiceFailure.init(error:),
                log: log,
                file: file,
                line: line
            )
        }
    }
}

// MARK: - Adapters

private extension RemoteServices.RequestFactory.CreateFastPaymentContractPayload {
    
    static func create(
        _ productID: FastPaymentsSettings.Product.ID
    ) -> Self {
        
        .init(
            selectableProductID: productID.selectableProductID,
            flagBankDefault: .empty,
            flagClientAgreementIn: .yes,
            flagClientAgreementOut: .yes
        )
    }
}

private extension RemoteServices.RequestFactory.UpdateFastPaymentContractPayload {
    
    static func create(
        _ payload: MicroServices.Facade.ContractUpdatePayload
    ) -> Self {
        
        switch payload.target {
        case .active:
            return .init(
                contractID: payload.contractID.rawValue,
                selectableProductID: payload.selectableProductID,
                flagBankDefault: .empty,
                flagClientAgreementIn: .yes,
                flagClientAgreementOut: .yes
            )
            
        case .inactive:
            return .init(
                contractID: payload.contractID.rawValue,
                selectableProductID: payload.selectableProductID,
                flagBankDefault: .empty,
                flagClientAgreementIn: .no,
                flagClientAgreementOut: .no
            )
        }
    }
}

extension ServiceFailure {
    
    init(
        error: RemoteServiceErrorOf<RemoteServices.ResponseMapper.MappingError>
    ) {
        switch error {
        case .createRequest, .performRequest:
            self = .connectivityError
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
            case .invalid:
                self = .connectivityError
                
            case let .server(_, errorMessage):
                self = .serverError(errorMessage)
            }
        }
    }
}
