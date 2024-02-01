//
//  MicroServices+GetSettingsMapper.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension MicroServices {
    
    final class GetSettingsMapper {
        
        private let getProducts: GetProducts
        
        public init(getProducts: @escaping GetProducts) {
            
            self.getProducts = getProducts
        }
    }
}

public extension MicroServices.GetSettingsMapper {
    
    func mapToSettings(
        paymentContract: UserPaymentSettings.PaymentContract,
        consentList: ConsentListState,
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
        
        let details = UserPaymentSettings.Details(
            paymentContract: paymentContract,
            consentList: consentList,
            bankDefaultResponse: bankDefaultResponse,
            productSelector: productSelector
        )
        
        return .contracted(details)
    }
}

public extension MicroServices.GetSettingsMapper {
    
    typealias GetProducts = () -> [Product]
}

