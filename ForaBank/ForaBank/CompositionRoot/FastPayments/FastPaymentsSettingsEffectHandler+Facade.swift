//
//  FastPaymentsSettingsEffectHandler+Facade.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.02.2024.
//

import C2BSubscriptionUI
import FastPaymentsSettings
import RemoteServices

extension FastPaymentsSettingsEffectHandler {
    
    typealias ForaRequestFactory = ForaBank.RequestFactory
    
    typealias FastResponseMapper = RemoteServices.ResponseMapper
    typealias FastRequestFactory = RemoteServices.RequestFactory
    
    convenience init(
        facade: MicroServices.Facade,
        httpClient: HTTPClient,
        getProducts: @escaping () -> [C2BSubscriptionUI.Product],
        log: @escaping (String, StaticString, UInt) -> Void
    ) {
        typealias ServiceFailure = FastPaymentsSettings.ServiceFailure
        
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
            createRequest: ForaRequestFactory.createGetC2BSubRequest,
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapGetC2BSubResponseResponse,
            mapOutput: { $0.getC2BSubResponse(getProducts()) },
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
    
    var payload: RemoteServices.RequestFactory.UpdateFastPaymentContractPayload {
        
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

// MARK: - Adapters

private extension GetC2BSubscription {
    
    func getC2BSubResponse(
        _ products: [C2BSubscriptionUI.Product]
    ) -> GetC2BSubResponse {
        
        .init(
            title: title,
            explanation: emptyList ?? [],
            details: {
                switch list {
                case .none:
                    return .empty
                case let .some(list):
                    return .list(list.compactMap {
                        
                        $0.getC2BProductSub(products)
                    })
                }
            }()
        )
    }
}

private extension GetC2BSubscription.ProductSubscription {
    
    func getC2BProductSub(
        _ products: [C2BSubscriptionUI.Product]
    ) -> GetC2BSubResponse.Details.ProductSubscription? {
        
        guard let product = products.first(where: { $0.id.matches(self) })
        else { return nil }
        
        return .init(
            product: product,
            subscriptions: subscription.map(\.sub)
        )
    }
}

private extension C2BSubscriptionUI.Product.ID {
    
    func matches(
        _ sub: GetC2BSubscription.ProductSubscription
    ) -> Bool {
        
        matches(sub.productId) && matches(sub.productType)
    }
    
    func matches(_ id: String) -> Bool {
        
        guard let id = Int(id) else { return false }
        
        switch self {
        case let .account(accountID): return accountID.rawValue == id
        case let .card(cardID): return cardID.rawValue == id
        }
    }
    
    func matches(
        _ productType: GetC2BSubscription.ProductSubscription.ProductType
    ) -> Bool {
        
        switch (self, productType) {
        case (.account, .account),
            (.card, .card):
            return true
            
        default:
            return false
        }
    }
}

private extension GetC2BSubscription.ProductSubscription.Subscription {
    
    var sub: GetC2BSubResponse.Details.ProductSubscription.Subscription {
        
        .init(
            token: .init(subscriptionToken),
            brandIcon: .svg(brandIcon),
            brandName: brandName,
            purpose: .init(subscriptionPurpose),
            cancelAlert: cancelAlert
        )
    }
}
