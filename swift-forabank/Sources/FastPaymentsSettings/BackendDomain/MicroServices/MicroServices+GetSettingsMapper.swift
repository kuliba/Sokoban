//
//  MicroServices+GetSettingsMapper.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension MicroServices {
    
    final class GetSettingsMapper {
        
        private let getProducts: GetProducts
        private let getBanks: GetBanks
        
        public init(
            getProducts: @escaping GetProducts,
            getBanks: @escaping GetBanks
        ) {
            self.getProducts = getProducts
            self.getBanks = getBanks
        }
    }
}

public extension MicroServices.GetSettingsMapper {
    
    func mapToSettings(
        paymentContract: UserPaymentSettings.PaymentContract,
        consent: Consent?,
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse
    ) -> UserPaymentSettings {
        
        let products = getProducts()
        let selectedProduct = products.product(
            forAccountID: paymentContract.accountID
        )
        
        let productSelector = UserPaymentSettings.ProductSelector(
            selectedProduct: selectedProduct,
            products: products,
            status: .collapsed
        )
        
        let consentListState = ConsentListState(banks: getBanks(), consent: consent)
        
        let details = UserPaymentSettings.Details(
            paymentContract: paymentContract,
            consentList: consentListState,
            bankDefaultResponse: bankDefaultResponse,
            productSelector: productSelector
        )
        
        return .contracted(details)
    }
}

extension ConsentListState {
    
    init(banks: [Bank], consent: Consent?) {
        
        if let consent {
            self = .success(.init(banks, consent: consent))
        } else {
            self = .failure(.collapsedError)
        }
    }
}

public extension MicroServices.GetSettingsMapper {
    
    typealias GetProducts = () -> [Product]
    typealias GetBanks = () -> [Bank]
}
