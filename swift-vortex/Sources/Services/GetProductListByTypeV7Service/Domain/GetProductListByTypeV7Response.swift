//
//  GetProductListByTypeV7Response.swift
//  
//
//  Created by Andryusina Nataly on 28.10.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public typealias GetProductListByTypeV7Response = SerialStamped<String, GetProductListByTypeV7Data>
}

extension ResponseMapper {
    
    public struct GetProductListByTypeV7Data: Equatable {
        
        public let commonProperties: CommonProperties
        public let uniqueProperties: UniqueProperties
        
        public init(
            commonProperties: CommonProperties,
            uniqueProperties: UniqueProperties
        ) {
            self.commonProperties = commonProperties
            self.uniqueProperties = uniqueProperties
        }
        
        public enum UniqueProperties: Equatable {
            
            case card(Card)
            case loan(Loan)
            case deposit(Deposit)
            case account(Account)
        }
    }
}

public extension ResponseMapper.GetProductListByTypeV7Data {
    
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
        
        public init(id: Int, productType: ProductType, productState: [ProductState], order: Int, visibility: Bool, number: String?, numberMasked: String?, accountNumber: String?, currency: String, mainField: String, additionalField: String?, customName: String?, productName: String, balance: Decimal?, balanceRUB: Decimal?, openDate: Int?, ownerId: Int, branchId: Int?, allowDebit: Bool, allowCredit: Bool, fontDesignColor: String, smallDesignMd5Hash: String, mediumDesignMd5Hash: String, largeDesignMd5Hash: String, xlDesignMd5Hash: String, smallBackgroundDesignHash: String, background: [String]) {
            self.id = id
            self.productType = productType
            self.productState = productState
            self.order = order
            self.visibility = visibility
            self.number = number
            self.numberMasked = numberMasked
            self.accountNumber = accountNumber
            self.currency = currency
            self.mainField = mainField
            self.additionalField = additionalField
            self.customName = customName
            self.productName = productName
            self.balance = balance
            self.balanceRUB = balanceRUB
            self.openDate = openDate
            self.ownerId = ownerId
            self.branchId = branchId
            self.allowDebit = allowDebit
            self.allowCredit = allowCredit
            self.fontDesignColor = fontDesignColor
            self.smallDesignMd5Hash = smallDesignMd5Hash
            self.mediumDesignMd5Hash = mediumDesignMd5Hash
            self.largeDesignMd5Hash = largeDesignMd5Hash
            self.xlDesignMd5Hash = xlDesignMd5Hash
            self.smallBackgroundDesignHash = smallBackgroundDesignHash
            self.background = background
        }
    }
}

public extension ResponseMapper.GetProductListByTypeV7Data {
    
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
        
        public init(cardID: Int, idParent: Int?, accountID: Int, cardType: CardType, statusCard: StatusCard, loanBaseParam: LoanBaseParam?, statusPC: StatusPC, name: String, validThru: Int, status: Status, expireDate: String, holderName: String, product: String, branch: String, paymentSystemName: String, paymentSystemImageMd5Hash: String) {
            self.cardID = cardID
            self.idParent = idParent
            self.accountID = accountID
            self.cardType = cardType
            self.statusCard = statusCard
            self.loanBaseParam = loanBaseParam
            self.statusPC = statusPC
            self.name = name
            self.validThru = validThru
            self.status = status
            self.expireDate = expireDate
            self.holderName = holderName
            self.product = product
            self.branch = branch
            self.paymentSystemName = paymentSystemName
            self.paymentSystemImageMd5Hash = paymentSystemImageMd5Hash
        }
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
        
        public init(loanID: Int, clientID: Int, number: String, currencyID: Int?, currencyNumber: Int?, currencyCode: String?, minimumPayment: Decimal?, gracePeriodPayment: Decimal?, overduePayment: Decimal?, availableExceedLimit: Decimal?, ownFunds: Decimal?, debtAmount: Decimal?, totalAvailableAmount: Decimal?, totalDebtAmount: Decimal?) {
            self.loanID = loanID
            self.clientID = clientID
            self.number = number
            self.currencyID = currencyID
            self.currencyNumber = currencyNumber
            self.currencyCode = currencyCode
            self.minimumPayment = minimumPayment
            self.gracePeriodPayment = gracePeriodPayment
            self.overduePayment = overduePayment
            self.availableExceedLimit = availableExceedLimit
            self.ownFunds = ownFunds
            self.debtAmount = debtAmount
            self.totalAvailableAmount = totalAvailableAmount
            self.totalDebtAmount = totalDebtAmount
        }
    }
}

public extension ResponseMapper.GetProductListByTypeV7Data {
    
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
        
        public init(currencyNumber: Int?, bankProductID: Int, amount: Decimal, currentInterestRate: Double, principalDebt: Decimal?, defaultPrincipalDebt: Decimal?, totalAmountDebt: Decimal?, principalDebtAccount: String, settlementAccount: String, settlementAccountId: Int, dateLong: Int, strDateLong: String) {
            self.currencyNumber = currencyNumber
            self.bankProductID = bankProductID
            self.amount = amount
            self.currentInterestRate = currentInterestRate
            self.principalDebt = principalDebt
            self.defaultPrincipalDebt = defaultPrincipalDebt
            self.totalAmountDebt = totalAmountDebt
            self.principalDebtAccount = principalDebtAccount
            self.settlementAccount = settlementAccount
            self.settlementAccountId = settlementAccountId
            self.dateLong = dateLong
            self.strDateLong = strDateLong
        }
    }
}

public extension ResponseMapper.GetProductListByTypeV7Data {
    
    struct Deposit: Equatable {
        
        public let depositProductID: Int
        public let depositID: Int
        public let interestRate: Double
        public let accountID: Int
        public let creditMinimumAmount: Decimal?
        public let minimumBalance: Decimal?
        public let endDate: Int?
        public let endDateNF: Bool
        public let demandDeposit: Bool
        public let isDebitInterestAvailable: Bool
        
        public init(depositProductID: Int, depositID: Int, interestRate: Double, accountID: Int, creditMinimumAmount: Decimal?, minimumBalance: Decimal?, endDate: Int?, endDateNF: Bool, demandDeposit: Bool, isDebitInterestAvailable: Bool) {
            self.depositProductID = depositProductID
            self.depositID = depositID
            self.interestRate = interestRate
            self.accountID = accountID
            self.creditMinimumAmount = creditMinimumAmount
            self.minimumBalance = minimumBalance
            self.endDate = endDate
            self.endDateNF = endDateNF
            self.demandDeposit = demandDeposit
            self.isDebitInterestAvailable = isDebitInterestAvailable
        }
    }
}

public extension ResponseMapper.GetProductListByTypeV7Data {
    
    struct Account: Equatable {
        
        public let name: String
        public let externalID: Int
        public let dateOpen: Int
        public let status: Status
        public let branchName: String
        public let detailedRatesUrl: String
        public let detailedConditionUrl: String
        public let isSavingAccount: Bool
        public let interestRate: String
        
        public init(name: String, externalID: Int, dateOpen: Int, status: Status, branchName: String, detailedRatesUrl: String, detailedConditionUrl: String, isSavingAccount: Bool, interestRate: String) {
            self.name = name
            self.externalID = externalID
            self.dateOpen = dateOpen
            self.status = status
            self.branchName = branchName
            self.detailedRatesUrl = detailedRatesUrl
            self.detailedConditionUrl = detailedConditionUrl
            self.isSavingAccount = isSavingAccount
            self.interestRate = interestRate
        }
    }
}

public extension ResponseMapper.GetProductListByTypeV7Data {
    
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
        case notActivated
        case blockedUnlockAvailable
        case issuedToClient
        case blockedByBank
        case notBlocked
        case blockedDebet
        case blockedCredit
        case blocked
        case blockedUnlockNotAvailable
    }

    enum CardType: Equatable {
        
        case main
        case regular
        case additionalSelf
        case additionalSelfAccOwn
        case additionalOther
        
        case additionalCorporate
        case corporate
        case individualBusinessman
        case individualBusinessmanMain
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
        case blockedUnlockNotAvailable
    }
}
