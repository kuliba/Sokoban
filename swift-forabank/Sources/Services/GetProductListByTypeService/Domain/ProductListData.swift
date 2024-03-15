//
//  ProductListData.swift
//
//
//  Created by Disman Dmitry on 14.03.2024.
//

import Foundation

public struct ProductListData: Equatable {
    
    public let serial: String?
    public let productList: [ProductList]
    
    public init(
        serial: String?,
        productList: [ProductList]
    ) {
        self.serial = serial
        self.productList = productList
    }
    
    public struct ProductList: Equatable {
        
        public let commonSettings: CommonProductSettings
        public let productSettings: ProductSettings
    }
    
    public enum ProductSettings: Equatable {

        case card(CardSettings)
        case loan(LoanSettings)
        case deposit(DepositSettings)
        case account(AccountSettings)
    }
}

public extension ProductListData {
    
    struct CommonProductSettings: Equatable {
        
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
        public let balance: Double?
        public let balanceRUB: Double?
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

public extension ProductListData {
    
    struct CardSettings: Equatable {
        
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
        public let minimumPayment: Double?
        public let gracePeriodPayment: Double?
        public let overduePayment: Double?
        public let availableExceedLimit: Double?
        public let ownFunds: Double?
        public let debtAmount: Double?
        public let totalAvailableAmount: Double?
        public let totalDebtAmount: Double?
    }
}

public extension ProductListData {
    
    struct LoanSettings: Decodable, Equatable {
        
        public let currencyNumber: Int?
        public let bankProductID: Int
        public let amount: Double
        public let currentInterestRate: Double
        public let principalDebt: Double?
        public let defaultPrincipalDebt: Double?
        public let totalAmountDebt: Double?
        public let principalDebtAccount: String
        public let settlementAccount: String
        public let settlementAccountId: Int
        public let dateLong: Int
        public let strDateLong: String
    }
}

public extension ProductListData {
    
    struct DepositSettings: Equatable {
        
        public let depositProductID: Int
        public let depositID: Int
        public let interestRate: Double
        public let accountID: Int
        public let creditMinimumAmount: Double?
        public let minimumBalance: Double
        public let endDate: Int?
        public let endDateNF: Bool
        public let demandDeposit: Bool
        public let isDebitInterestAvailable: Bool
    }
}

public extension ProductListData {
    
    struct AccountSettings: Equatable {
        
        public let name: String
        public let externalID: Int
        public let dateOpen: Int
        public let status: Status
        public let branchName: String
        public let detailedRatesUrl: String
        public let detailedConditionUrl: String
    }
}

public extension ProductListData {
    
    enum ProductType: String, Equatable {
        
        case account = "ACCOUNT"
        case card = "CARD"
        case deposit = "DEPOSIT"
        case loan = "LOAN"
    }

    enum StatusCard: Equatable {
        
        case active
        case blockedUnlockAvailable
        case blockedUnlockNotAvailable
        case notActivated
    }
    
    enum Status: String, Equatable {
        
        case blockedByClient
        case active
        case issuedToClient
        case blockedByBank
        case notBlocked
        case blockedDebet
        case blockedCredit
        case blocked
        case unknown
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
        case unknown
    }
}
