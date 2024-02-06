//
//  RootViewModelFactory+makeFastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

import FastPaymentsSettings
import Foundation
import UserAccountNavigationComponent

extension RootViewModelFactory {
    
    // TODO: Remove after `legacy` case eliminated
    static func makeFastPaymentsFactory(
        httpClient: HTTPClient,
        model: Model,
        log: @escaping (String, StaticString, UInt) -> Void,
        fastPaymentsSettingsFlag: FastPaymentsSettingsFlag
    ) -> FastPaymentsFactory {
        
        switch fastPaymentsSettingsFlag.rawValue {
        case .active:
            return .init(fastPaymentsViewModel: .new({
                
                makeNewFastPaymentsViewModel(
                    httpClient: httpClient,
                    model: model,
                    log: log,
                    scheduler: $0
                )
            }))
            
        case .inactive:
            return .init(
                fastPaymentsViewModel: .legacy({
                    
                    MeToMeSettingView.ViewModel(
                        model: $0,
                        newModel: model,
                        closeAction: $1
                    )
                })
            )
        }
    }
    
    static func makeNewFastPaymentsViewModel(
        useStub isStub: Bool = true,
        httpClient: HTTPClient,
        model: Model,
        log: @escaping (String, StaticString, UInt) -> Void,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) -> FastPaymentsSettingsViewModel {
        
        let getProducts = isStub ? { .preview } : model.getProducts
        let getBanks = isStub ? { [] } : model.getBanks
        
#warning("add BankDefault caching")
        let getBankDefaultResponse: MicroServices.Facade.GetBankDefaultResponse = NanoServices.makeDecoratedGetBankDefault(httpClient, { nil }, { _ in }, log)
        
        let facade: MicroServices.Facade = isStub
        ? .stub(getProducts, getBanks)
        : .live(httpClient, getProducts, getBanks, getBankDefaultResponse, log)
        
        let bankDefaultReducer = BankDefaultReducer()
        let consentListReducer = ConsentListRxReducer()
        let contractReducer = ContractReducer(getProducts: getProducts)
        let productsReducer = ProductsReducer(getProducts: getProducts)
        
        let reducer = FastPaymentsSettingsReducer(
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:),
            consentListReduce: consentListReducer.reduce(_:_:),
            contractReduce: contractReducer.reduce(_:_:),
            productsReduce: productsReducer.reduce(_:_:)
        )
        
        let effectHandler = FastPaymentsSettingsEffectHandler(
            facade: facade,
            httpClient: httpClient,
            log: log
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

// MARK: - Live

private extension Model {
    
    func getBanks() -> [FastPaymentsSettings.Bank] {
        
        bankListFullInfo.value.compactMap(FastPaymentsSettings.Bank.init(info:))
    }
}

private extension FastPaymentsSettings.Bank {
    
    init?(info: BankFullInfoData) {
        
        guard let id = info.memberId else { return nil }
        
        self.init(id: .init(id), name: info.displayName)
    }
}

private extension Model {
    
#warning("getProducts should employ this requirements for products attributes https://shorturl.at/jtxzS")
#warning("getProducts is expected to sort products in order that would taking first that is `active` and `main`")
    // https://shorturl.at/yTW35
    func getProducts() -> [Product] {
        
        let formatBalance = { [weak self] in
            
            self?.formattedBalance(of: $0) ?? ""
        }
        
        return allProducts.compactMap {
            $0.fastPaymentsProduct(formatBalance: formatBalance)
        }
    }
}

private extension ProductData {
    
    func fastPaymentsProduct(
        formatBalance: @escaping (ProductData) -> String
    ) -> FastPaymentsSettings.Product? {
        
        switch productType {
        case .account:
            guard let account = self as? ProductAccountData,
                  account.status == .notBlocked,
                  account.currency == rub
            else { return nil }
            
            return account.fpsProduct(formatBalance: formatBalance)
            
        case .card:
            guard let card = self as? ProductCardData,
                  let accountID = card.accountId,
                  (card.isMain ?? false),
                  card.status == .active,
                  card.statusPc == .active,
                  card.currency == rub
            else { return nil }
            
            return card.fpsProduct(
                accountID: accountID,
                formatBalance: formatBalance
            )
            
        default:
            return nil
        }
    }
    
    private var rub: String { "RUB" }
}

private extension ProductAccountData {
    
    func fpsProduct(
        formatBalance: @escaping (ProductData) -> String
    ) -> FastPaymentsSettings.Product {
        
        .init(
            id: .account(.init(id)),
            header: "Счет списания",
            title: displayName,
            number: displayNumber ?? "",
            amountFormatted: formatBalance(self),
            balance: .init(balanceValue),
            look: .init(
                background: .svg(largeDesign.description),
                color: backgroundColor.description,
                icon: .svg(smallDesign.description)
            )
        )
    }
}

private extension ProductCardData {
    
    func fpsProduct(
        accountID: Int,
        formatBalance: @escaping (ProductData) -> String
    ) -> FastPaymentsSettings.Product {
        
        .init(
            id: .card(.init(id), accountID: .init(accountID)),
            header: "Счет списания",
            title: displayName,
            number: displayNumber ?? "",
            amountFormatted: formatBalance(self),
            balance: .init(balanceValue),
            look: .init(
                background: .svg(largeDesign.description),
                color: backgroundColor.description,
                icon: .svg(smallDesign.description)
            )
        )
    }
}
