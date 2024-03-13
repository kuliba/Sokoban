//
//  ProductListData.swift
//  
//
//  Created by Disman Dmitry on 14.03.2024.
//

import Foundation

public struct ProductListData: Equatable {
    
    let serial: String?
    let productList: [ProductList]
    
    public init(
        serial: String?,
        productList: [ProductList]
    ) {
        self.serial = serial
        self.productList = productList
    }
    
    public struct ProductList: Equatable {
        
        let commonSettings: CommonProductSettings
        let productSettings: ProductSettings
    }
    
    enum ProductSettings: Equatable {

        case card(CardSettings)
        case loan(LoanSettings)
        case deposit(DepositSettings)
        case account(AccountSettings)
    }
}

public extension ProductListData {
    
    struct CommonProductSettings: Equatable {
        
        let id: Int
        let productType: ProductType
        let productState: [String]
        let order: Int
        let visibility: Bool
        let number: String
        let numberMasked: String
        let accountNumber: String
        let currency: String
        let mainField: String
        let additionalField: String?
        let customName: String?
        let productName: String
        let balance: Double?
        let balanceRUB: Double?
        let openDate: Int
        let ownerId: Int
        let branchId: Int
        let allowDebit: Bool
        let allowCredit: Bool
        let fontDesignColor: String
        let smallDesignMd5Hash: String
        let mediumDesignMd5Hash: String
        let largeDesignMd5Hash: String
        let xlDesignMd5Hash: String
        let smallBackgroundDesignHash: String
        let background: [String]
    }
}

public extension ProductListData {
    
    struct CardSettings: Equatable {
        
        let cardID: Int
        let idParent: Int?
        let accountID: Int
        let cardType: CardType
        let statusCard: StatusCard
        let loanBaseParam: LoanBaseParam?
        let statusPC: StatusPC
        let miniStatement: [Payment]
        let name: String
        let validThru: Int
        let status: Status
        let expireDate: String
        let holderName: String
        let product: String
        let branch: String
        let paymentSystemName: String
        let paymentSystemImageMd5Hash: String
    }
    
    struct LoanBaseParam: Equatable {
        
        let loanID: Int
        let clientID: Int
        let number: String
        let currencyID: Int?
        let currencyNumber: Int?
        let currencyCode: String?
        let minimumPayment: Double?
        let gracePeriodPayment: Double?
        let overduePayment: Double?
        let availableExceedLimit: Double?
        let ownFunds: Double?
        let debtAmount: Double?
        let totalAvailableAmount: Double?
        let totalDebtAmount: Double?
    }
}

public extension ProductListData {
    
    struct LoanSettings: Decodable, Equatable {
        
        let currencyNumber: Int?
        let bankProductID: Int
        let amount: Double
        let currentInterestRate: Double
        let principalDebt: Double?
        let defaultPrincipalDebt: Double?
        let totalAmountDebt: Double?
        let principalDebtAccount: String
        let settlementAccount: String
        let settlementAccountId: Int
        let dateLong: Int
        let strDateLong: String
    }
}

public extension ProductListData {
    
    struct DepositSettings: Equatable {
        
        let depositProductID: Int
        let depositID: Int
        let interestRate: Double
        let cardID: Int
        let accountID: Int
        let creditMinimumAmount: Double
        let minimumBalance: Double
        let endDate: Int
        let endDateNF: Bool
        let demandDeposit: Bool
        let isDebitInterestAvailable: Bool?
        let name: String
        let validThru: Int
        let expireDate: String
        let holderName: String
        let product: String
        let branch: String
        let miniStatement: [Payment]
        let paymentSystemName: String
        let paymentSystemImageMd5Hash: String
        let idParent: Int?
        let cardType: CardType
        let statusCard: StatusCard
        let loanBaseParam: LoanBaseParam?
        let statusPC: StatusPC
    }
}

public extension ProductListData {
    
    struct AccountSettings: Equatable {
        
        let name: String
        let externalID: Int
        let dateOpen: Int
        let status: Status
        let branchName: String
        let miniStatement: [Payment]
        let detailedRatesUrl: String
        let detailedConditionUrl: String
    }
}

public extension ProductListData {
    
    struct Payment: Equatable {
        
        let account: String
        let date: Int
        let amount: Double
        let currency: String
        let purpose: String
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
    
    enum Status: Equatable {
        
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
