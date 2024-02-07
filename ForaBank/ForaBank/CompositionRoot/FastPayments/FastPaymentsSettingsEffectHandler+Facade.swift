//
//  FastPaymentsSettingsEffectHandler+Facade.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.02.2024.
//

import FastPaymentsSettings

extension FastPaymentsSettingsEffectHandler {
    
    typealias ForaRequestFactory = ForaBank.RequestFactory
    
    typealias FastResponseMapper = FastPaymentsSettings.ResponseMapper
    typealias FastRequestFactory = FastPaymentsSettings.RequestFactory
    
    convenience init(
        facade: MicroServices.Facade,
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) {
        let changeConsentList: ConsentListRxEffectHandler.ChangeConsentList = NanoServices.adaptedLoggingFetch(
            createRequest: {
                try ForaRequestFactory.createChangeClientConsentMe2MePullRequest($0.map { .init($0.rawValue) })
            },
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapChangeClientConsentMe2MePullResponse,
            mapOutput: { () in ConsentListRxEffectHandler.OK() },
            mapError: ServiceFailure.init(error:),
            log: log
        )
        
        let consentListHandler = ConsentListRxEffectHandler(
            changeConsentList: changeConsentList
        )
        
        let contractMaker = facade.makeContractMaker()
        let contractUpdater = facade.makeContractUpdater()
        
        let contractEffectHandler = ContractEffectHandler(
            createContract: { contractMaker.process($0.id, $1) },
            updateContract: { contractUpdater.process($0.updaterPayload, $1) }
        )
        
        let getC2BSub = NanoServices.adaptedLoggingFetch(
            createRequest: NanoServices.ForaRequestFactory.createGetC2BSubRequest,
            httpClient: httpClient,
            mapResponse: NanoServices.FastResponseMapper.mapGetC2BSubResponseResponse,
            mapOutput: \.getC2BSubResponse,
            mapError: ServiceFailure.init(error:),
            log: log
        )
        
        let prepareSetBankDefault = NanoServices.adaptedLoggingFetch(
            createRequest: ForaRequestFactory.createPrepareSetBankDefaultRequest,
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapPrepareSetBankDefaultResponse,
            mapError: ServiceFailure.init(error:),
            log: log
        )
        
        let updateProduct: FastPaymentsSettingsEffectHandler.UpdateProduct = NanoServices.adaptedLoggingFetch(
            createRequest: {
                
                try ForaRequestFactory.createUpdateFastPaymentContractRequest($0.payload)
            },
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapUpdateFastPaymentContractResponse,
            mapError: ServiceFailure.init(error:),
            log: log
        )
        
        self.init(
            handleConsentListEffect: consentListHandler.handleEffect(_:_:),
            handleContractEffect: contractEffectHandler.handleEffect(_:_:),
            getC2BSub: getC2BSub,
            getSettings: facade.getSettings(),
            prepareSetBankDefault: prepareSetBankDefault,
            updateProduct: updateProduct
        )
    }
}

// MARK: - Adapters

private extension FastPaymentsSettingsEffectHandler.UpdateProductPayload {
    
    var payload: FastPaymentsSettings.RequestFactory.UpdateFastPaymentContractPayload {
        
        .init(
            contractID: .init(contractID.rawValue),
            selectableProductID: selectableProductID,
            flagBankDefault: .empty,
            flagClientAgreementIn: .yes,
            flagClientAgreementOut: .yes
        )
    }
}

private extension ContractEffect.TargetContract {
    
    typealias Payload = MicroServices.Facade.ContractUpdater.Payload
    
    var updaterPayload: Payload {
        
        .init(
            contractID: .init(core.contractID.rawValue),
            selectableProductID: core.selectableProductID,
            target: payloadTarget
        )
    }
    
    var payloadTarget: Payload.TargetStatus {
        
        switch targetStatus {
        case .active: return .active
        case .inactive: return .inactive
        }
    }
}

#warning("remove mapping after changing return type of `static ResponseMapper.mapGetC2BSubResponseResponse(_:_:)` to `GetC2BSubResponse`")
// MARK: - Adapters

private extension GetC2BSubscription {
    
    var getC2BSubResponse: GetC2BSubResponse {
        
        .init(
            title: title,
            explanation: emptyList ?? [],
            details: {
                switch list {
                case .none:
                    return .empty
                case let .some(list):
                    return .list(list.map(\.getC2BProductSub))
                }
            }()
        )
    }
}

private extension GetC2BSubscription.ProductSubscription {
    
    var getC2BProductSub: GetC2BSubResponse.Details.ProductSubscription {
        
        .init(
            productID: productId,
            productType: {
                switch productType {
                case .account: return .account
                case .card: return .card
                }
            }(),
            productTitle: productTitle,
            subscriptions: subscription.map(\.sub)
        )
    }
}

private extension GetC2BSubscription.ProductSubscription.Subscription {
    
    var sub: GetC2BSubResponse.Details.ProductSubscription.Subscription {
        
        .init(
            subscriptionToken: subscriptionToken,
            brandIcon: brandIcon,
            brandName: brandName,
            subscriptionPurpose: subscriptionPurpose,
            cancelAlert: cancelAlert
        )
    }
}
