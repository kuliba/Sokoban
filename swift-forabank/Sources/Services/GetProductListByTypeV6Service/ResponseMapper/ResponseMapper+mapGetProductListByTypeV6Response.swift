//
//  ResponseMapper+mapGetProductListByTypeV6Response.swift
//
//
//  Created by Andryusina Nataly on 14.08.2024.
//

import Foundation
import RemoteServices

public typealias ResponseMapper = RemoteServices.ResponseMapper
public typealias MappingError = RemoteServices.ResponseMapper.MappingError

public extension ResponseMapper {
    
    typealias GetProductListByTypeV6Result = Result<ProductsResponse, MappingError>
    
    static func mapGetProductListByTypeV6Response(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> GetProductListByTypeV6Result {
        
        map(data, response, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> ProductsResponse {
        
        ProductsResponse(data: data)
    }
}

private extension ResponseMapper {
    
    typealias _Data = ProductListWrapperDTO
}

private extension ResponseMapper {

    struct ProductListWrapperDTO: Decodable {
        
        let serial: String?
        let productList: [ProductListDTO]
    }
    
    struct ProductListDTO: Decodable {
        
        let commonSettings: CommonSettingsDTO
        let productSettings: ProductSettingsDTO
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.singleValueContainer()
            
            commonSettings = try container.decode(CommonSettingsDTO.self)
            
            switch commonSettings.productType {
            case .account:
                productSettings = .account(try container.decode(AccountSettingsDTO.self))
                
            case .card:
                productSettings = .card(try container.decode(CardSettingsDTO.self))

            case .deposit:
                productSettings = .deposit(try container.decode(DepositSettingsDTO.self))
                
            case .loan:
                productSettings = .loan(try container.decode(LoanSettingsDTO.self))
            }
        }
    }
    
    enum ProductSettingsDTO: Decodable, Equatable {

        case card(CardSettingsDTO)
        case loan(LoanSettingsDTO)
        case deposit(DepositSettingsDTO)
        case account(AccountSettingsDTO)
    }
}

// MARK: - PaymentDTO

private extension ResponseMapper {
    
    struct PaymentDTO: Decodable, Equatable {
        
        let account: String
        let date: Int
        let amount: Double
        let currency: String
        let purpose: String
    }
}

// MARK: - BaseSettingsDTO

private extension ResponseMapper {
    
    struct CommonSettingsDTO: Decodable {
        
        let id: Int
        let productType: ProductTypeDTO
        let productState: [ProductStateDTO]
        let order: Int
        let visibility: Bool
        let number: String?
        let numberMasked: String?
        let accountNumber: String?
        let currency: String
        let mainField: String
        let additionalField: String?
        let customName: String?
        let productName: String
        let balance: Double?
        let balanceRUB: Double?
        let openDate: Int?
        let ownerID: Int
        let branchId: Int?
        let allowDebit: Bool
        let allowCredit: Bool
        let fontDesignColor: String
        let smallDesignMd5hash: String
        let mediumDesignMd5hash: String
        let largeDesignMd5hash: String
        let XLDesignMd5hash: String
        let smallBackgroundDesignHash: String
        let background: [String]
    }
}

// MARK: - CardSettingsDTO

private extension ResponseMapper {
    
    struct CardSettingsDTO: Decodable, Equatable {
        
        let cardID: Int
        let idParent: Int?
        let accountID: Int
        let cardType: CardTypeDTO
        let statusCard: StatusCardDTO
        let loanBaseParam: LoanBaseParamDTO?
        let statusPC: StatusPCDTO
        let name: String
        let validThru: Int
        let status: StatusDTO
        let expireDate: String
        let holderName: String
        let product: String
        let branch: String
        let paymentSystemName: String
        let paymentSystemImageMd5Hash: String
    }
    
    struct LoanBaseParamDTO: Decodable, Equatable {
        
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

//MARK: - LoanSettingsDTO

private extension ResponseMapper {
    
    struct LoanSettingsDTO: Decodable, Equatable {
        
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

//MARK: - DepositSettingsDTO

private extension ResponseMapper {
    
    struct DepositSettingsDTO: Decodable, Equatable {
        
        let depositProductID: Int
        let depositID: Int
        let interestRate: Double
        let accountID: Int
        let creditMinimumAmount: Double?
        let minimumBalance: Double?
        let endDate: Int?
        let endDate_nf: Bool
        let demandDeposit: Bool
        let isDebitInterestAvailable: Bool
    }
}

//MARK: - AccountSettingsDTO

private extension ResponseMapper {
    
    struct AccountSettingsDTO: Decodable, Equatable {
        
        let name: String
        let externalID: Int
        let dateOpen: Int
        let status: StatusDTO
        let branchName: String
        let detailedRatesUrl: String
        let detailedConditionUrl: String
    }
}

private extension ResponseMapper {
    
    enum ProductTypeDTO: String, Decodable {
        
        case account = "ACCOUNT"
        case card = "CARD"
        case deposit = "DEPOSIT"
        case loan = "LOAN"
    }
    
    enum StatusCardDTO: String, Decodable {
        
        case active = "ACTIVE"
        case blockedUnlockAvailable = "BLOCKED_UNLOCK_AVAILABLE"
        case blockedUnlockNotAvailable = "BLOCKED_UNLOCK_NOT_AVAILABLE"
        case notActivated = "NOT_ACTIVE"
    }
    
    enum StatusDTO: String, Decodable {
        
        case blockedByClient = "Блокирована по решению Клиента"
        case active = "Действует"
        case notActivated = "Не активирована"
        case issuedToClient = "Выдано клиенту"
        case blockedByBank = "Заблокирована банком"
        case blockedUnlockAvailable = "Карта блокирована, разблокировка доступна"
        case notBlocked = "NOT_BLOCKED"
        case blockedDebet = "BLOCKED_DEBET"
        case blockedCredit = "BLOCKED_CREDIT"
        case blocked = "BLOCKED"
    }

    enum CardTypeDTO: String, Decodable {
        
        case main = "MAIN"
        case regular = "REGULAR"
        case additionalSelf = "ADDITIONAL_SELF"
        case additionalSelfAccOwn = "ADDITIONAL_SELF_ACC_OWN"
        case additionalOther = "ADDITIONAL_OTHER"
        
        case additionalCorporate = "ADDITIONAL_CORPORATE"
        case corporate = "CORPORATE"
        case individualBusinessman = "INDIVIDUAL_BUSINESSMAN"
        case individualBusinessmanMain = "INDIVIDUAL_BUSINESSMAN_MAIN"
    }
    
    enum ProductStateDTO: String, Decodable {
        
        case `default` = "DEFAULT"
        case notActivated = "NOT_ACTIVATION"
        case blocked = "BLOCKED"
        case notVisible = "NOT_VISIBILITY"
        case blockedNotVisible = "BLOCKED_NOT_VISIBILITY"
    }
    
    enum StatusPCDTO: String, Decodable {
        
        case active = "0"
        case operationsBlocked = "3"
        case blockedByBank = "5"
        case lost = "6"
        case stolen = "7"
        case notActivated = "17"
        case temporarilyBlocked = "20"
        case blockedByClient = "21"
        case blockedUnlockNotAvailable = "23"
    }
}

private extension ProductsResponse.ProductType {
    
    init(productTypeDTO: ResponseMapper.ProductTypeDTO) {
        
        switch productTypeDTO {
        case .account:
            self = .account
            
        case .card:
            self = .card
            
        case .deposit:
            self = .deposit
            
        case .loan:
            self = .loan
        }
    }
}

private extension ProductsResponse.Status {
    
    init(statusDTO: ResponseMapper.StatusDTO) {
        
        switch statusDTO {
        case .blockedByClient:
            self = .blockedByClient
            
        case .active:
            self = .active
            
        case .issuedToClient:
            self = .issuedToClient
            
        case .blockedByBank:
            self = .blockedByBank
            
        case .notBlocked:
            self = .notBlocked
            
        case .blockedDebet:
            self = .blockedDebet
            
        case .blockedCredit:
            self = .blockedCredit
            
        case .blocked:
            self = .blocked
            
        case .notActivated:
            self = .notActivated
            
        case .blockedUnlockAvailable:
            self = .blockedUnlockAvailable
        }
    }
}

private extension ProductsResponse.LoanBaseParam {
    
    init(loanDTO: ResponseMapper.LoanBaseParamDTO) {
                
        self.init(
            loanID: loanDTO.loanID,
            clientID: loanDTO.clientID,
            number: loanDTO.number,
            currencyID: loanDTO.currencyID,
            currencyNumber: loanDTO.currencyNumber,
            currencyCode: loanDTO.currencyCode,
            minimumPayment: loanDTO.minimumPayment.map{ Decimal($0) },
            gracePeriodPayment: loanDTO.gracePeriodPayment.map{ Decimal($0) },
            overduePayment: loanDTO.overduePayment.map{ Decimal($0) },
            availableExceedLimit: loanDTO.availableExceedLimit.map{ Decimal($0) },
            ownFunds: loanDTO.ownFunds.map{ Decimal($0) },
            debtAmount: loanDTO.debtAmount.map{ Decimal($0) },
            totalAvailableAmount: loanDTO.totalAvailableAmount.map{ Decimal($0) },
            totalDebtAmount: loanDTO.totalDebtAmount.map{ Decimal($0) }
        )
    }
}

private extension ProductsResponse.StatusPC {
    
    init(statusPCDTO: ResponseMapper.StatusPCDTO) {
        
        switch statusPCDTO {
        case .active:
            self = .active
            
        case .operationsBlocked:
            self = .operationsBlocked
            
        case .blockedByBank:
            self = .blockedByBank
            
        case .lost:
            self = .lost
            
        case .stolen:
            self = .stolen
            
        case .notActivated:
            self = .notActivated
            
        case .temporarilyBlocked:
            self = .temporarilyBlocked
            
        case .blockedByClient:
            self = .blockedByClient
            
        case .blockedUnlockNotAvailable:
            self = .blockedUnlockNotAvailable
        }
    }
}

private extension ProductsResponse.StatusCard {
    
    init(statusCardDTO: ResponseMapper.StatusCardDTO) {
        
        switch statusCardDTO {
        case .active:
            self = .active
            
        case .blockedUnlockAvailable:
            self = .blockedUnlockAvailable
            
        case .blockedUnlockNotAvailable:
            self = .blockedUnlockNotAvailable
            
        case .notActivated:
            self = .notActivated
        }
    }
}

private extension ProductsResponse.CardType {
    
    init(cardTypeDTO: ResponseMapper.CardTypeDTO) {
        
        switch cardTypeDTO {
        case .main:
            self = .main
            
        case .regular:
            self = .regular
            
        case .additionalSelf:
            self = .additionalSelf
            
        case .additionalSelfAccOwn:
            self = .additionalSelfAccOwn
            
        case .additionalOther:
            self = .additionalOther
            
        case .additionalCorporate:
            self = .additionalCorporate
            
        case .corporate:
            self = .corporate
            
        case .individualBusinessman:
            self = .individualBusinessman
            
        case .individualBusinessmanMain:
            self = .individualBusinessmanMain
        }
    }
}

private extension ProductsResponse.ProductState {
    
    init(productStateDTO: ResponseMapper.ProductStateDTO) {
        
        switch productStateDTO {
        case .default:
            self = .default
            
        case .notActivated:
            self = .notActivated
            
        case .blocked:
            self = .blocked
            
        case .notVisible:
            self = .notVisible
            
        case .blockedNotVisible:
            self = .blockedNotVisible
        }
    }
}

private extension ProductsResponse.Product {
    
    init(_ data: ResponseMapper.ProductListDTO) {
        
        self.init(
            commonProperties: .init(data.commonSettings),
            uniqueProperties: .init(data.productSettings)
        )
    }
}

private extension ProductsResponse.CommonProperties {
    
    init(_ data: ResponseMapper.CommonSettingsDTO) {
        
        self.init(
            id: data.id,
            productType: .init(productTypeDTO: data.productType),
            productState: data.productState.map{ .init(productStateDTO: $0) },
            order: data.order,
            visibility: data.visibility,
            number: data.number,
            numberMasked: data.numberMasked,
            accountNumber: data.accountNumber,
            currency: data.currency,
            mainField: data.mainField,
            additionalField: data.additionalField,
            customName: data.customName,
            productName: data.productName,
            balance: data.balance.map{ Decimal($0) },
            balanceRUB: data.balanceRUB.map{ Decimal($0) },
            openDate: data.openDate,
            ownerId: data.ownerID,
            branchId: data.branchId,
            allowDebit: data.allowDebit,
            allowCredit: data.allowCredit,
            fontDesignColor: data.fontDesignColor,
            smallDesignMd5Hash: data.smallDesignMd5hash,
            mediumDesignMd5Hash: data.mediumDesignMd5hash,
            largeDesignMd5Hash: data.largeDesignMd5hash,
            xlDesignMd5Hash: data.XLDesignMd5hash,
            smallBackgroundDesignHash: data.smallBackgroundDesignHash,
            background: data.background
        )
    }
}

private extension ProductsResponse.UniqueProperties {
    
    init(_ data: ResponseMapper.ProductSettingsDTO) {
        
        switch data {
        case let .card(card):
            self = .card(.init(card))
            
        case let .loan(loan):
            self = .loan(.init(loan))
            
        case let .deposit(deposit):
            self = .deposit(.init(deposit))
            
        case let .account(account):
            self = .account(.init(account))
        }
    }
}

private extension ProductsResponse.Card {
    
    init(_ data: ResponseMapper.CardSettingsDTO) {
        
        self.init(
            cardID: data.cardID,
            idParent: data.idParent,
            accountID: data.accountID,
            cardType: .init(cardTypeDTO: data.cardType),
            statusCard: .init(statusCardDTO: data.statusCard),
            loanBaseParam: data.loanBaseParam.map{ .init(loanDTO: $0) },
            statusPC: .init(statusPCDTO: data.statusPC),
            name: data.name,
            validThru: data.validThru,
            status: .init(statusDTO: data.status),
            expireDate: data.expireDate,
            holderName: data.holderName,
            product: data.product,
            branch: data.branch,
            paymentSystemName: data.paymentSystemName,
            paymentSystemImageMd5Hash: data.paymentSystemImageMd5Hash
        )
    }
}

private extension ProductsResponse.Loan {
    
    init(_ data: ResponseMapper.LoanSettingsDTO) {
        
        self.init(
            currencyNumber: data.currencyNumber,
            bankProductID: data.bankProductID,
            amount: Decimal(data.amount),
            currentInterestRate: data.currentInterestRate,
            principalDebt: data.principalDebt.map{ Decimal($0) },
            defaultPrincipalDebt: data.defaultPrincipalDebt.map{ Decimal($0) },
            totalAmountDebt: data.totalAmountDebt.map{ Decimal($0) },
            principalDebtAccount: data.principalDebtAccount,
            settlementAccount: data.settlementAccount,
            settlementAccountId: data.settlementAccountId,
            dateLong: data.dateLong,
            strDateLong: data.strDateLong
        )
    }
}

private extension ProductsResponse.Deposit {
    
    init(_ data: ResponseMapper.DepositSettingsDTO) {
        
        self.init(
            depositProductID: data.depositProductID,
            depositID: data.depositID,
            interestRate: data.interestRate,
            accountID: data.accountID,
            creditMinimumAmount: data.creditMinimumAmount.map{ Decimal($0) },
            minimumBalance: Decimal(data.minimumBalance ?? 0.0),
            endDate: data.endDate,
            endDateNF: data.endDate_nf,
            demandDeposit: data.demandDeposit,
            isDebitInterestAvailable: data.isDebitInterestAvailable
        )
    }
}

private extension ProductsResponse.Account {
    
    init(_ data: ResponseMapper.AccountSettingsDTO) {
        
        self.init(
            name: data.name,
            externalID: data.externalID,
            dateOpen: data.dateOpen,
            status: .init(statusDTO: data.status),
            branchName: data.branchName,
            detailedRatesUrl: data.detailedRatesUrl,
            detailedConditionUrl: data.detailedConditionUrl
        )
    }
}

private extension ProductsResponse {
    
    init(data: ResponseMapper._Data) {
        
        self.init(
            serial: data.serial,
            products: data.productList.map(ProductsResponse.Product.init)
        )
    }
}
