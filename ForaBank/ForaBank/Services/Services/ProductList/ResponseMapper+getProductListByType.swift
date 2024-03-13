//
//  ResponseMapper+getProductListByType.swift
//  ForaBank
//
//  Created by Disman Dmitry on 10.03.2024.
//

import Foundation

extension ResponseMapper {
    
    typealias ProductList = ServerCommands.ProductController.GetProductListByType.Response.List
    
    typealias GetProductListByTypeResult = Result<ProductList, GetProductListByTypeResultError>
    
    static func mapMakeProductListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetProductListByTypeResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                
                let makeTransferResponse = try JSONDecoder().decode(
                    ServerResponse<ProductList>.self,
                    from: data
                )
                
                guard let productList = makeTransferResponse.data else {
                    
                    return .failure(.invalidData(
                        statusCode: httpURLResponse.statusCode, data: data
                    ))
                }
                
                return .success(productList)
                
            default:
                
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
            
        } catch {
            
            guard let error = try? JSONDecoder().decode(ServerError.self, from: data) else {

                return .failure(.invalidData(
                    statusCode: httpURLResponse.statusCode, data: data
                ))
            }

            return .failure(.error(
                statusCode: error.statusCode,
                errorMessage: error.errorMessage)
            )
        }
    }
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
            productSettings = try container.decode(ProductSettingsDTO.self)
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
        let cardID: Int
        let accountID: Int
        let creditMinimumAmount: Double
        let minimumBalance: Double
        let endDate: Int
        let endDate_nf: Bool
        let demandDeposit: Bool
        let isDebitInterestAvailable: Bool?
        let name: String
        let validThru: Int
        let expireDate: String
        let holderName: String
        let product: String
        let branch: String
        let miniStatement: [PaymentDTO]
        let paymentSystemName: String
        let paymentSystemImageMd5Hash: String
        let idParent: Int?
        let cardType: CardTypeDTO
        let statusCard: StatusCardDTO
        let loanBaseParam: LoanBaseParamDTO?
        let statusPC: StatusPCDTO
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
    
    enum StatusPCDTO: String, Codable {
        
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

private extension ProductType {
    
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

private extension ProductData.Status {
    
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

private extension PaymentData {
    
    convenience init(paymentDTO: ResponseMapper.PaymentDTO) {
        
        self.init(
            date: Date.dateUTC(with: paymentDTO.date),
            account: paymentDTO.account,
            currency: paymentDTO.currency,
            amount: paymentDTO.amount,
            purpose: paymentDTO.purpose
        )
    }
}

private extension ProductCardData.PaymentDataItem {
    
    init(paymentDTO: ResponseMapper.PaymentDTO) {
        
        self.init(
            account: paymentDTO.account,
            date: Date.dateUTC(with: paymentDTO.date),
            amount: paymentDTO.amount,
            currency: paymentDTO.currency,
            purpose: paymentDTO.currency
        )
    }
}

private extension ProductCardData.LoanBaseParamInfoData {
    
    init(loanDTO: ResponseMapper.LoanBaseParamDTO?) {
        
        self.init(
            loanId: loanDTO?.loanID ?? 0,
            clientId: loanDTO?.clientID ?? 0,
            number: loanDTO?.number ?? "",
            currencyId: loanDTO?.currencyID,
            currencyNumber: loanDTO?.currencyNumber,
            currencyCode: loanDTO?.currencyCode,
            minimumPayment: loanDTO?.minimumPayment,
            gracePeriodPayment: loanDTO?.gracePeriodPayment,
            overduePayment: loanDTO?.overduePayment,
            availableExceedLimit: loanDTO?.availableExceedLimit,
            ownFunds: loanDTO?.ownFunds,
            debtAmount: loanDTO?.debtAmount,
            totalAvailableAmount: loanDTO?.totalAvailableAmount,
            totalDebtAmount: loanDTO?.totalDebtAmount
        )
    }
}

private extension ProductData.StatusPC {
    
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
