//
//  MicroServices+GetSettingsMapper.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension MicroServices {
    
    final class GetSettingsMapper {
        
        private let getProducts: GetProducts
        private let getSelectableBanks: GetSelectableBanks
        
        public init(
            getProducts: @escaping GetProducts,
            getSelectableBanks: @escaping GetSelectableBanks
        ) {
            self.getProducts = getProducts
            self.getSelectableBanks = getSelectableBanks
        }
    }
}

public extension MicroServices.GetSettingsMapper {
    
    func mapToSettings(
        paymentContract: UserPaymentSettings.PaymentContract,
        consent: Consent?,
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse
    ) -> UserPaymentSettings {
        
        let accountID = paymentContract.productID
        let products = getProducts()
        let selectedProduct = products.first { $0.id == accountID }
        
        let productSelector = UserPaymentSettings.ProductSelector(
            selectedProduct: selectedProduct,
            products: products,
            status: .collapsed
        )
        
        let consentListState: ConsentListState = {
            
            guard let consent
            else { return .failure(.collapsedError) }
            
            return .success(.init(
                banks: getSelectableBanks(),
                consent: consent,
                mode: .collapsed,
                searchText: ""
            ))
        }()
        
        let details = UserPaymentSettings.Details(
            paymentContract: paymentContract,
            consentList: consentListState,
            bankDefaultResponse: bankDefaultResponse,
            productSelector: productSelector
        )
        
        return .contracted(details)
    }
}

public extension MicroServices.GetSettingsMapper {
    
    typealias GetProducts = () -> [Product]
    typealias GetSelectableBanks = () -> [ConsentList.SelectableBank]
}
