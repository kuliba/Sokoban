//
//  Parameters+ProductSelect.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

import Tagged

public extension Parameters {
    
    struct ProductSelect: Equatable {
        
        let id: ID
        let value: String?
        let title: String
        let filter: Filter
        
        public init(
            id: ID,
            value: String?,
            title: String,
            filter: Filter
        ) {
            self.id = id
            self.value = value
            self.title = title
            self.filter = filter
        }
    }
}

public extension Parameters.ProductSelect {
    
    typealias ID = Tagged<_ID, String>
    enum _ID {}
    
    struct Filter: Equatable {
        
        let productTypes: [ProductType]
        let currencies: [Currency]
        let additional: Bool
        
        public init(
            productTypes: [ProductType],
            currencies: [Currency],
            additional: Bool
        ) {
            self.productTypes = productTypes
            self.currencies = currencies
            self.additional = additional
        }
    }
}

public extension Parameters.ProductSelect.Filter {
    
    enum ProductType: Equatable {
        
        case card
        case account
    }
    
    enum Currency {
        
        case rub
    }
}
