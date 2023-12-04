//
//  ProductSelect.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

extension GetSberQRDataResponse.Parameter {

    struct ProductSelect: Equatable {
        
        let id: String
        let value: String?
        let title: String
        let filter: Filter
        
        struct Filter: Equatable {
            
            let productTypes: [ProductType]
            let currencies: [Currency]
            let additional: Bool
            
            enum ProductType: Equatable {
                
                case card
                case account
            }
            
            enum Currency {
                
                case rub
            }
        }
    }
}
