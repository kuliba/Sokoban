//
//  ProductResponse.swift
//
//
//  Created by Disman Dmitry on 14.03.2024.
//

import Foundation

public struct ProductResponse: Equatable {
    
    public let serial: String?
    public let products: [Product]
    
    public init(
        serial: String?,
        products: [Product]
    ) {
        self.serial = serial
        self.products = products
    }
    
    public struct Product: Equatable {
        
        public let commonProperties: CommonProperties
        public let uniqueProperties: UniqueProperties
    }
    
    public enum UniqueProperties: Equatable {

        case card(Card)
        case loan(Loan)
        case deposit(Deposit)
        case account(Account)
    }
}

public extension ProductResponse {
    
    struct CommonProperties: Equatable {
        
        public let id: Int
        public let productType: ProductType
        public let productState: [ProductState]
        public let order: Int
        public let visibility: Bool
        public let number: String?
        public let numberMasked: String?
        public let accountNumber: String?
        public let currency: String
        public let mainField: String
        public let additionalField: String?
        public let customName: String?
        public let productName: String
        public let balance: Decimal?
        public let balanceRUB: Decimal?
        public let openDate: Int?
        public let ownerId: Int
        public let branchId: Int?
        public let allowDebit: Bool
        public let allowCredit: Bool
        public let fontDesignColor: String
        public let smallDesignMd5Hash: String
        public let mediumDesignMd5Hash: String
        public let largeDesignMd5Hash: String
        public let xlDesignMd5Hash: String
        public let smallBackgroundDesignHash: String
        public let background: [String]
    }
}

public extension ProductResponse {
    
    struct Card: Equatable {
        
        public let cardID: Int
        public let idParent: Int?
        public let accountID: Int
        public let cardType: CardType
        public let statusCard: StatusCard
        public let loanBaseParam: LoanBaseParam?
        public let statusPC: StatusPC
        public let name: String
        public let validThru: Int
        public let status: Status
        public let expireDate: String
        public let holderName: String
        public let product: String
        public let branch: String
        public let paymentSystemName: String
        public let paymentSystemImageMd5Hash: String
    }
    
    struct LoanBaseParam: Equatable {
        
        public let loanID: Int
        public let clientID: Int
        public let number: String
        public let currencyID: Int?
        public let currencyNumber: Int?
        public let currencyCode: String?
        public let minimumPayment: Decimal?
        public let gracePeriodPayment: Decimal?
        public let overduePayment: Decimal?
        public let availableExceedLimit: Decimal?
        public let ownFunds: Decimal?
        public let debtAmount: Decimal?
        public let totalAvailableAmount: Decimal?
        public let totalDebtAmount: Decimal?
    }
}

public extension ProductResponse {
    
    struct Loan: Equatable {
        
        public let currencyNumber: Int?
        public let bankProductID: Int
        public let amount: Decimal
        public let currentInterestRate: Double
        public let principalDebt: Decimal?
        public let defaultPrincipalDebt: Decimal?
        public let totalAmountDebt: Decimal?
        public let principalDebtAccount: String
        public let settlementAccount: String
        public let settlementAccountId: Int
        public let dateLong: Int
        public let strDateLong: String
    }
}

public extension ProductResponse {
    
    struct Deposit: Equatable {
        
        public let depositProductID: Int
        public let depositID: Int
        public let interestRate: Double
        public let accountID: Int
        public let creditMinimumAmount: Decimal?
        public let minimumBalance: Decimal
        public let endDate: Int?
        public let endDateNF: Bool
        public let demandDeposit: Bool
        public let isDebitInterestAvailable: Bool
    }
}

public extension ProductResponse {
    
    struct Account: Equatable {
        
        public let name: String
        public let externalID: Int
        public let dateOpen: Int
        public let status: Status
        public let branchName: String
        public let detailedRatesUrl: String
        public let detailedConditionUrl: String
    }
}

public extension ProductResponse {
    
    enum ProductType: Equatable {
        
        case account
        case card
        case deposit
        case loan
    }

    enum StatusCard: Equatable {
        
        case active
        case blockedUnlockAvailable
        case blockedUnlockNotAvailable
        case notActivated
    }
    
    enum Status: Equatable {
        
        case blockedByClient
        case active
        case issuedToClient
        case blockedByBank
        case notBlocked
        case blockedDebet
        case blockedCredit
        case blocked
    }

    enum CardType: Equatable {
        
        case main
        case regular
        case additionalSelf
        case additionalSelfAccOwn
        case additionalOther
    }
    
    enum ProductState: Equatable {
        
        case `default`
        case notActivated
        case blocked
        case notVisible
        case blockedNotVisible
    }
    
    enum StatusPC: Equatable {
        
        case active
        case operationsBlocked
        case blockedByBank
        case lost
        case stolen
        case notActivated
        case temporarilyBlocked
        case blockedByClient
    }
}
