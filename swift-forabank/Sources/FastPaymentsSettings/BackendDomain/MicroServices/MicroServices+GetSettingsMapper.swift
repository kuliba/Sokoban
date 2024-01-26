//
//  MicroServices+GetSettingsMapper.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension MicroServices {
    
    final class GetSettingsMapper {
        
#warning("getProducts should employ this requirements for products attributes https://www.figma.com/file/BYCudUIJc4iYr8Ngaorg0Y/10.-%D0%9F%D1%80%D0%BE%D1%84%D0%B8%D0%BB%D1%8C-%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8F.-%D0%9D%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B8-%D0%A1%D0%91%D0%9F?type=whiteboard&node-id=1150-24599&t=N2MxHOWGDL4bt3IB-4")
#warning("getProducts is expected to sort products in order that would taking first that is `active` and `main`")
        
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
        
        let details = UserPaymentSettings.ContractDetails(
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

