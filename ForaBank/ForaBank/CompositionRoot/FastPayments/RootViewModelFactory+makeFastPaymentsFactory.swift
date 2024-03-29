//
//  RootViewModelFactory+makeFastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

import C2BSubscriptionUI
import FastPaymentsSettings
import Foundation
import UserAccountNavigationComponent
import SwiftUI

extension RootViewModelFactory {
    
    static func makeNewFastPaymentsViewModel(
        httpClient: HTTPClient,
        model: Model,
        log: @escaping (String, StaticString, UInt) -> Void,
        scheduler: AnySchedulerOfDispatchQueue
    ) -> FastPaymentsSettingsViewModel {
        
        let getProducts = /*isStub ? { .preview } :*/ model.getFastPaymentsSettingsProducts
        let getBanks = /*isStub ? { [] } :*/ model.getBanks
        
        let getBankDefaultResponse: MicroServices.Facade.GetBankDefaultResponse = NanoServices.makeDecoratedGetBankDefault(httpClient, log)
        
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
        
        let facade = MicroServices.Facade(httpClient, getProducts, getBanks, getBankDefaultResponse, log)
        
        let effectHandler = FastPaymentsSettingsEffectHandler(
            facade: facade,
            httpClient: httpClient, 
            getProducts: model.getC2BSubscriptionProducts,
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
        
        // https://shorturl.at/dxCV4
        bankListFullInfo.value
            .filter {
                $0.receiverList.contains("ME2MEPULL")
                && $0.memberId != "100000000217"
            }
            .compactMap(FastPaymentsSettings.Bank.init(info:))
            .sorted(by: \.name)
    }
}

private extension FastPaymentsSettings.Bank {
    
    init?(info: BankFullInfoData) {
        
        guard let id = info.memberId else { return nil }
        
        self.init(
            id: .init(id), 
            name: info.displayName,
            image: info.svgImage.image ?? .ic24Bank.renderingMode(.template)
        )
    }
}

private extension Model {
    
#warning("getProducts should employ this requirements for products attributes https://shorturl.at/jtxzS")
#warning("getProducts is expected to sort products in order that would taking first that is `active` and `main`")
    // https://shorturl.at/yTW35
    func getFastPaymentsSettingsProducts(
    ) -> [FastPaymentsSettings.Product] {
        
        let formatBalance = { [weak self] in
            
            self?.formattedBalance(of: $0) ?? ""
        }
        
        let getLook = { [weak self] in
                
            self?.look(of: $0) ?? .default
        }
        
        return allProducts.compactMap {
            $0.fastPaymentsProduct(formatBalance: formatBalance, getLook: getLook)
        }
    }
    
    func look(
        of productData: ProductData
    ) -> FastPaymentsSettings.Product.Look {
       
        .init(
            background: .image(self.images.value[productData.largeDesignMd5Hash]?.image ?? .cardPlaceholder),
            color: productData.backgroundColor.description,
            icon: .image(self.images.value[productData.smallDesignMd5hash]?.image ?? .cardPlaceholder)
        )
    }
    
    func getC2BSubscriptionProducts(
    ) -> [C2BSubscriptionUI.Product] {
        
        let formatBalance = { [weak self] in
            
            self?.formattedBalance(of: $0) ?? ""
        }
        
        return allProducts.compactMap {
            $0.c2bSubscriptionUIProduct(formatBalance: formatBalance, getImage: { self.images.value[$0]?.image })
        }
    }
}

private extension FastPaymentsSettings.Product.Look {
    
    static let `default`: Self = .init(
        background: .image(.cardPlaceholder),
        color: Color.clear.description,
        icon: .image(.cardPlaceholder))
}

private extension ProductData {
    
    func fastPaymentsProduct(
        formatBalance: @escaping (ProductData) -> String,
        getLook: @escaping (ProductData) -> FastPaymentsSettings.Product.Look
    ) -> FastPaymentsSettings.Product? {
     
        let look = getLook(self)

        switch productType {
        case .account:
            guard let account = self as? ProductAccountData,
                  account.status == .notBlocked,
                  account.currency == rub
            else { return nil }
            
            
            return account.fpsProduct(
                formatBalance: formatBalance,
                look: look
            )
            
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
                formatBalance: formatBalance,
                look: look
            )
            
        default:
            return nil
        }
    }
    
    func c2bSubscriptionUIProduct(
        formatBalance: @escaping (ProductData) -> String,
        getImage: @escaping (Md5hash) -> Image?
    ) -> C2BSubscriptionUI.Product? {
        
        switch productType {
        case .account:
            guard let account = self as? ProductAccountData,
                  account.status == .notBlocked,
                  account.currency == rub
            else { return nil }
            
            return account.c2bProduct(formatBalance: formatBalance, getImage: getImage)
            
        case .card:
            guard let card = self as? ProductCardData,
                  let accountID = card.accountId,
                  (card.isMain ?? false),
                  card.status == .active,
                  card.statusPc == .active,
                  card.currency == rub
            else { return nil }
            
            return card.c2bProduct(
                accountID: accountID,
                formatBalance: formatBalance,
                getImage: getImage
            )
            
        default:
            return nil
        }
    }
    
    private var rub: String { "RUB" }
}

private extension ProductAccountData {
    
    func fpsProduct(
        formatBalance: @escaping (ProductData) -> String,
        look: FastPaymentsSettings.Product.Look
    ) -> FastPaymentsSettings.Product {
        
        .init(
            id: .account(.init(id)),
            header: "Счет списания",
            title: displayName,
            number: displayNumber ?? "",
            amountFormatted: formatBalance(self),
            balance: .init(balanceValue),
            look: look
        )
    }
    
    func c2bProduct(
        formatBalance: @escaping (ProductData) -> String,
        getImage: @escaping (Md5hash) -> Image?
    ) -> C2BSubscriptionUI.Product {
        
        .init(
            id: .account(.init(id)),
            title: "Счет списания",
            name: displayName,
            number: displayNumber ?? "",
            icon: .image(getImage(smallDesignMd5hash) ?? .cardPlaceholder),
            balance: formatBalance(self)
        )
    }
}

private extension ProductCardData {
    
    func fpsProduct(
        accountID: Int,
        formatBalance: @escaping (ProductData) -> String,
        look: FastPaymentsSettings.Product.Look
    ) -> FastPaymentsSettings.Product {
        
        .init(
            id: .card(.init(id), accountID: .init(accountID)),
            header: "Счет списания",
            title: displayName,
            number: displayNumber ?? "",
            amountFormatted: formatBalance(self),
            balance: .init(balanceValue),
            look: look
        )
    }
    
    func c2bProduct(
        accountID: Int,
        formatBalance: @escaping (ProductData) -> String,
        getImage: @escaping (Md5hash) -> Image?
    ) -> C2BSubscriptionUI.Product {
        
        .init(
            id: .card(.init(id)),
            title: "Счет списания",
            name: displayName,
            number: displayNumber ?? "",
            icon: .image(getImage(smallDesignMd5hash) ?? .cardPlaceholder),
            balance: formatBalance(self)
        )
    }
}
