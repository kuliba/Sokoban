//
//  ResponseMapper+getProductListByType.swift
//  ForaBank
//
//  Created by Disman Dmitry on 10.03.2024.
//

import Foundation
import Services

public typealias ResponseMapper = Services.ResponseMapper
public typealias MappingError = Services.ResponseMapper.MappingError

public extension ResponseMapper {
    
    typealias GetProductListByTypeResult = Result<ProductListData, MappingError>
    
    static func mapGetCardStatementResponse(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> GetProductListByTypeResult {
        
        map(data, response, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> ProductListData {
        
        ProductListData(data: data)
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
        let miniStatement: [PaymentDTO]
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
        let isDebitInterestAvailable: Bool?
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
        let miniStatement: [PaymentDTO]
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
        case issuedToClient = "Выдано клиенту"
        case blockedByBank = "Заблокирована банком"
        case notBlocked = "NOT_BLOCKED"
        case blockedDebet = "BLOCKED_DEBET"
        case blockedCredit = "BLOCKED_CREDIT"
        case blocked = "BLOCKED"
        case unknown
    }

    enum CardTypeDTO: String, Decodable {
        
        case main = "MAIN"
        case regular = "REGULAR"
        case additionalSelf = "ADDITIONAL_SELF"
        case additionalSelfAccOwn = "ADDITIONAL_SELF_ACC_OWN"
        case additionalOther = "ADDITIONAL_OTHER"
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
        case unknown
    }
}

private extension ProductListData.ProductType {
    
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

private extension ProductListData.Status {
    
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
            
        case .unknown:
            self = .unknown
        }
    }
}

private extension ProductListData.Payment {
    
    init(paymentDTO: ResponseMapper.PaymentDTO) {
        
        self.init(
            account: paymentDTO.account,
            date: paymentDTO.date,
            amount: paymentDTO.amount,
            currency: paymentDTO.currency,
            purpose: paymentDTO.purpose
        )
    }
}

private extension ProductListData.LoanBaseParam {
    
    init?(loanDTO: ResponseMapper.LoanBaseParamDTO?) {
        
        guard let loanDTO else { return nil }
        
        self.init(
            loanID: loanDTO.loanID,
            clientID: loanDTO.clientID,
            number: loanDTO.number,
            currencyID: loanDTO.currencyID,
            currencyNumber: loanDTO.currencyNumber,
            currencyCode: loanDTO.currencyCode,
            minimumPayment: loanDTO.minimumPayment,
            gracePeriodPayment: loanDTO.gracePeriodPayment,
            overduePayment: loanDTO.overduePayment,
            availableExceedLimit: loanDTO.availableExceedLimit,
            ownFunds: loanDTO.ownFunds,
            debtAmount: loanDTO.debtAmount,
            totalAvailableAmount: loanDTO.totalAvailableAmount,
            totalDebtAmount: loanDTO.totalDebtAmount
        )
    }
}

private extension ProductListData.StatusPC {
    
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
            
        case .unknown:
            self = .unknown
        }
    }
}

private extension ProductListData.StatusCard {
    
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

private extension ProductListData.CardType {
    
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
        }
    }
}

private extension ProductListData.ProductState {
    
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

private extension ProductListData {
    
    init(data: ResponseMapper._Data) {
        
        let productList: [ProductList] = data.productList.map {
            
            let commonSettings = ProductListData.CommonProductSettings(
                id: $0.commonSettings.id,
                productType: .init(productTypeDTO: $0.commonSettings.productType),
                productState: $0.commonSettings.productState.map { .init(productStateDTO: $0) },
                order: $0.commonSettings.order,
                visibility: $0.commonSettings.visibility,
                number: $0.commonSettings.number,
                numberMasked: $0.commonSettings.numberMasked,
                accountNumber: $0.commonSettings.accountNumber,
                currency: $0.commonSettings.currency,
                mainField: $0.commonSettings.mainField,
                additionalField: $0.commonSettings.additionalField,
                customName: $0.commonSettings.customName,
                productName: $0.commonSettings.productName,
                balance: $0.commonSettings.balance,
                balanceRUB: $0.commonSettings.balanceRUB,
                openDate: $0.commonSettings.openDate,
                ownerId: $0.commonSettings.ownerID,
                branchId: $0.commonSettings.branchId,
                allowDebit: $0.commonSettings.allowDebit,
                allowCredit: $0.commonSettings.allowCredit,
                fontDesignColor: $0.commonSettings.fontDesignColor,
                smallDesignMd5Hash: $0.commonSettings.smallDesignMd5hash,
                mediumDesignMd5Hash: $0.commonSettings.mediumDesignMd5hash,
                largeDesignMd5Hash: $0.commonSettings.largeDesignMd5hash,
                xlDesignMd5Hash: $0.commonSettings.XLDesignMd5hash,
                smallBackgroundDesignHash: $0.commonSettings.smallBackgroundDesignHash,
                background: $0.commonSettings.background
            )
            
            let productSettings: ProductSettings
            
            switch $0.productSettings {
            case .card(let cardSettingsDTO):
                
                productSettings = .card(.init(
                    cardID: cardSettingsDTO.cardID,
                    idParent: cardSettingsDTO.idParent,
                    accountID: cardSettingsDTO.accountID,
                    cardType: .init(cardTypeDTO: cardSettingsDTO.cardType),
                    statusCard: .init(statusCardDTO: cardSettingsDTO.statusCard),
                    loanBaseParam: .init(loanDTO: cardSettingsDTO.loanBaseParam),
                    statusPC: .init(statusPCDTO: cardSettingsDTO.statusPC),
                    miniStatement: cardSettingsDTO.miniStatement.map { .init(paymentDTO: $0) },
                    name: cardSettingsDTO.name,
                    validThru: cardSettingsDTO.validThru,
                    status: .init(statusDTO: cardSettingsDTO.status),
                    expireDate: cardSettingsDTO.expireDate,
                    holderName: cardSettingsDTO.holderName,
                    product: cardSettingsDTO.product,
                    branch: cardSettingsDTO.branch,
                    paymentSystemName: cardSettingsDTO.paymentSystemName,
                    paymentSystemImageMd5Hash: cardSettingsDTO.paymentSystemImageMd5Hash
                ))
                                
            case .loan(let loanSettingsDTO):
                
                productSettings = .loan(.init(
                    currencyNumber: loanSettingsDTO.currencyNumber,
                    bankProductID: loanSettingsDTO.bankProductID,
                    amount: loanSettingsDTO.amount,
                    currentInterestRate: loanSettingsDTO.currentInterestRate,
                    principalDebt: loanSettingsDTO.principalDebt,
                    defaultPrincipalDebt: loanSettingsDTO.defaultPrincipalDebt,
                    totalAmountDebt: loanSettingsDTO.totalAmountDebt,
                    principalDebtAccount: loanSettingsDTO.principalDebtAccount,
                    settlementAccount: loanSettingsDTO.settlementAccount,
                    settlementAccountId: loanSettingsDTO.settlementAccountId,
                    dateLong: loanSettingsDTO.dateLong,
                    strDateLong: loanSettingsDTO.strDateLong))
                
            case .deposit(let depositSettingsDTO):

                productSettings = .deposit(.init(
                    depositProductID: depositSettingsDTO.depositProductID,
                    depositID: depositSettingsDTO.depositID,
                    interestRate: depositSettingsDTO.interestRate,
                    accountID: depositSettingsDTO.accountID,
                    creditMinimumAmount: depositSettingsDTO.creditMinimumAmount,
                    minimumBalance: depositSettingsDTO.minimumBalance,
                    endDate: depositSettingsDTO.endDate,
                    endDateNF: depositSettingsDTO.endDate_nf,
                    demandDeposit: depositSettingsDTO.demandDeposit,
                    isDebitInterestAvailable: depositSettingsDTO.isDebitInterestAvailable))
                
            case .account(let accountSettingsDTO):
                
                productSettings = .account(.init(
                    name: accountSettingsDTO.name,
                    externalID: accountSettingsDTO.externalID,
                    dateOpen: accountSettingsDTO.dateOpen,
                    status: .init(statusDTO: accountSettingsDTO.status),
                    branchName: accountSettingsDTO.branchName,
                    miniStatement: accountSettingsDTO.miniStatement.map { .init(paymentDTO: $0) },
                    detailedRatesUrl: accountSettingsDTO.detailedRatesUrl,
                    detailedConditionUrl: accountSettingsDTO.detailedConditionUrl))
            }
            
            return ProductList(
                commonSettings: commonSettings,
                productSettings: productSettings
            )
        }

        self = .init(serial: data.serial, productList: productList)
    }
}
