//
//  UserPaymentSettings.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Tagged

public enum UserPaymentSettings: Equatable {
    
    case contracted(ContractDetails)
    case missingContract(ConsentResult)
    case failure(Failure)
}

public extension UserPaymentSettings {
    
    struct ContractDetails: Equatable {
        
        public var paymentContract: PaymentContract
        public let consentResult: ConsentResult
        public var bankDefault: BankDefault
        public var productSelector: ProductSelector
        
        public init(
            paymentContract: PaymentContract,
            consentResult: ConsentResult,
            bankDefault: BankDefault,
            productSelector: ProductSelector
        ) {
            self.paymentContract = paymentContract
            self.consentResult = consentResult
            self.bankDefault = bankDefault
            self.productSelector = productSelector
        }
    }
    
    struct PaymentContract: Equatable, Identifiable {
        
        public let id: ContractID
        public let productID: Product.ID
        public let contractStatus: ContractStatus
        
        public init(
            id: ContractID,
            productID: Product.ID,
            contractStatus: ContractStatus
        ) {
            self.id = id
            self.productID = productID
            self.contractStatus = contractStatus
        }
        
        public typealias ContractID = Tagged<_ContractID, Int>
        public enum _ContractID {}
        
        public enum ContractStatus: Equatable {
            
            case active, inactive
        }
    }
    
    struct ProductSelector: Equatable {
        
        public let selectedProduct: Product?
        public let products: [Product]
        public let status: Status
        
        public init(
            selectedProduct: Product?,
            products: [Product],
            status: Status = .collapsed
        ) {
            self.selectedProduct = selectedProduct
            self.products = products
            self.status = status
        }
        
        public enum Status: Equatable {
            
            case collapsed, expanded
        }
    }
}

public extension UserPaymentSettings {
    
    typealias ConsentResult = Result<ConsentList, ConsentError>
    
    struct ConsentList: Equatable {
        
        public init() {}
    }
    
    struct ConsentError: Error, Equatable {
        
        public init() {}
    }
    
    enum BankDefault: Equatable {
        
        case onDisabled
        case offEnabled
        case offDisabled
    }
}

public extension UserPaymentSettings {
    
    enum Failure: Equatable {
        
        case connectivityError
        case serverError(String)
    }
}
