//
//  Services+makeGetProductListByTypeResult.swift
//  ForaBank
//
//  Created by Disman Dmitry on 14.03.2024.
//

import Foundation
import GetProductListByTypeService

extension Services {
        
    typealias ProductList = ServerCommands.ProductController.GetProductListByType.Response.List
    
    static func makeGetProductListByTypeResult(
        httpClient: HTTPClient,
        payload: GetProductListByTypePayload
    ) async throws -> ProductList {
        
        let data = try await Services.makeGetProductListByTypeService(
            httpClient: httpClient
        ).process(payload)
        
        return mapProductList(data)
    }
}

private extension Services {
    
    static func mapProductList(_ productListData: ProductListData) -> ProductList {
        
        let serial = productListData.serial
        
        let productList: [ProductData] = productListData.productList.map {
            
            switch $0.productSettings {
            case .card(let cardSettingsDTO):
                
                let cardData = ProductCardData(
                    id: $0.commonSettings.id,
                    productType: .init(productType: $0.commonSettings.productType),
                    number: $0.commonSettings.number,
                    numberMasked: $0.commonSettings.numberMasked,
                    accountNumber: $0.commonSettings.accountNumber,
                    balance: $0.commonSettings.balance,
                    balanceRub: $0.commonSettings.balanceRUB,
                    currency: $0.commonSettings.currency,
                    mainField: $0.commonSettings.mainField,
                    additionalField: $0.commonSettings.additionalField,
                    customName: $0.commonSettings.customName,
                    productName: $0.commonSettings.productName,
                    openDate: date(for: $0.commonSettings.openDate),
                    ownerId: $0.commonSettings.ownerId,
                    branchId: $0.commonSettings.branchId,
                    allowCredit: $0.commonSettings.allowCredit,
                    allowDebit: $0.commonSettings.allowDebit,
                    extraLargeDesign: .init(description: $0.commonSettings.xlDesignMd5Hash),
                    largeDesign: .init(description: $0.commonSettings.largeDesignMd5Hash),
                    mediumDesign: .init(description: $0.commonSettings.mediumDesignMd5Hash),
                    smallDesign: .init(description: $0.commonSettings.smallDesignMd5Hash),
                    fontDesignColor: .init(description: $0.commonSettings.fontDesignColor),
                    background: $0.commonSettings.background.map { ColorData(description: $0) },
                    accountId: cardSettingsDTO.accountID,
                    cardId: cardSettingsDTO.cardID,
                    name: cardSettingsDTO.name,
                    validThru: Date.dateUTC(with: cardSettingsDTO.validThru),
                    status: .init(status: cardSettingsDTO.status),
                    expireDate: cardSettingsDTO.expireDate,
                    holderName: cardSettingsDTO.holderName,
                    product: cardSettingsDTO.product,
                    branch: cardSettingsDTO.branch,
                    miniStatement: cardSettingsDTO.miniStatement.map { .init(paymentDataItem: $0) },
                    paymentSystemName: cardSettingsDTO.paymentSystemName,
                    paymentSystemImage: .init(description: cardSettingsDTO.paymentSystemImageMd5Hash),
                    loanBaseParam: .init(loan: cardSettingsDTO.loanBaseParam),
                    statusPc: .init(statusPC: cardSettingsDTO.statusPC),
                    isMain: cardSettingsDTO.cardType == .main,
                    externalId: nil,
                    order: $0.commonSettings.order,
                    visibility: $0.commonSettings.visibility,
                    smallDesignMd5hash: $0.commonSettings.smallDesignMd5Hash,
                    smallBackgroundDesignHash: $0.commonSettings.smallBackgroundDesignHash
                )
                
                cardData.statusCard = .init(statusCard: cardSettingsDTO.statusCard)
                cardData.cardType = .init(cardType: cardSettingsDTO.cardType)
                cardData.idParent = cardSettingsDTO.idParent
                
                return cardData
                
            case .loan(let loanSettingsDTO):
                
                return ProductLoanData(
                    id: $0.commonSettings.id,
                    productType: .init(productType: $0.commonSettings.productType),
                    number: $0.commonSettings.number,
                    numberMasked: $0.commonSettings.numberMasked,
                    accountNumber: $0.commonSettings.accountNumber,
                    balance: $0.commonSettings.balance,
                    balanceRub: $0.commonSettings.balanceRUB,
                    currency: $0.commonSettings.currency,
                    mainField: $0.commonSettings.mainField,
                    additionalField: $0.commonSettings.additionalField,
                    customName: $0.commonSettings.customName,
                    productName: $0.commonSettings.productName,
                    openDate: date(for: $0.commonSettings.openDate),
                    ownerId: $0.commonSettings.ownerId,
                    branchId: $0.commonSettings.branchId,
                    allowCredit: $0.commonSettings.allowCredit,
                    allowDebit: $0.commonSettings.allowDebit,
                    extraLargeDesign: .init(description: $0.commonSettings.xlDesignMd5Hash),
                    largeDesign: .init(description: $0.commonSettings.largeDesignMd5Hash),
                    mediumDesign: .init(description: $0.commonSettings.mediumDesignMd5Hash),
                    smallDesign: .init(description: $0.commonSettings.smallDesignMd5Hash),
                    fontDesignColor: .init(description: $0.commonSettings.fontDesignColor),
                    background: $0.commonSettings.background.map { ColorData(description: $0) },
                    currencyNumber: loanSettingsDTO.currencyNumber,
                    bankProductId: loanSettingsDTO.bankProductID,
                    amount: loanSettingsDTO.amount,
                    currentInterestRate: loanSettingsDTO.currentInterestRate,
                    principalDebt: loanSettingsDTO.principalDebt,
                    defaultPrincipalDebt: loanSettingsDTO.defaultPrincipalDebt,
                    totalAmountDebt: loanSettingsDTO.totalAmountDebt,
                    principalDebtAccount: loanSettingsDTO.principalDebtAccount,
                    settlementAccount: loanSettingsDTO.settlementAccount,
                    settlementAccountId: loanSettingsDTO.settlementAccountId,
                    dateLong: Date.dateUTC(with: loanSettingsDTO.dateLong),
                    strDateLong: loanSettingsDTO.strDateLong,
                    order: $0.commonSettings.order,
                    visibility: $0.commonSettings.visibility,
                    smallDesignMd5hash: $0.commonSettings.smallDesignMd5Hash,
                    smallBackgroundDesignHash: $0.commonSettings.smallBackgroundDesignHash)
                
            case .deposit(let depositSettingsDTO):
                
                return ProductDepositData(
                    id: $0.commonSettings.id,
                    productType: .init(productType: $0.commonSettings.productType),
                    number: $0.commonSettings.number,
                    numberMasked: $0.commonSettings.numberMasked,
                    accountNumber: $0.commonSettings.accountNumber,
                    balance: $0.commonSettings.balance,
                    balanceRub: $0.commonSettings.balanceRUB,
                    currency: $0.commonSettings.currency,
                    mainField: $0.commonSettings.mainField,
                    additionalField: $0.commonSettings.additionalField,
                    customName: $0.commonSettings.customName,
                    productName: $0.commonSettings.productName,
                    openDate: date(for: $0.commonSettings.openDate),
                    ownerId: $0.commonSettings.ownerId,
                    branchId: $0.commonSettings.branchId,
                    allowCredit: $0.commonSettings.allowCredit,
                    allowDebit: $0.commonSettings.allowDebit,
                    extraLargeDesign: SVGImageData(description: $0.commonSettings.xlDesignMd5Hash),
                    largeDesign: SVGImageData(description: $0.commonSettings.largeDesignMd5Hash),
                    mediumDesign: SVGImageData(description: $0.commonSettings.mediumDesignMd5Hash),
                    smallDesign: SVGImageData(description: $0.commonSettings.smallDesignMd5Hash),
                    fontDesignColor: ColorData(description: $0.commonSettings.fontDesignColor),
                    background: $0.commonSettings.background.map { ColorData(description: $0) },
                    depositProductId: depositSettingsDTO.depositProductID,
                    depositId: depositSettingsDTO.depositID,
                    interestRate: depositSettingsDTO.interestRate,
                    accountId: depositSettingsDTO.accountID,
                    creditMinimumAmount: depositSettingsDTO.creditMinimumAmount ?? 0,
                    minimumBalance: depositSettingsDTO.minimumBalance ?? 0,
                    endDate: date(for: depositSettingsDTO.endDate),
                    endDateNf: depositSettingsDTO.endDateNF,
                    isDemandDeposit: depositSettingsDTO.demandDeposit,
                    isDebitInterestAvailable: depositSettingsDTO.isDebitInterestAvailable,
                    order: $0.commonSettings.order,
                    visibility: $0.commonSettings.visibility,
                    smallDesignMd5hash: $0.commonSettings.smallDesignMd5Hash,
                    smallBackgroundDesignHash: $0.commonSettings.smallBackgroundDesignHash)
                
            case .account(let accountSettingsDTO):
                
                return ProductAccountData(
                    id: $0.commonSettings.id,
                    productType: .init(productType: $0.commonSettings.productType),
                    number: $0.commonSettings.number,
                    numberMasked: $0.commonSettings.numberMasked,
                    accountNumber: $0.commonSettings.accountNumber,
                    balance: $0.commonSettings.balance,
                    balanceRub: $0.commonSettings.balanceRUB,
                    currency: $0.commonSettings.currency,
                    mainField: $0.commonSettings.mainField,
                    additionalField: $0.commonSettings.additionalField,
                    customName: $0.commonSettings.customName,
                    productName: $0.commonSettings.productName,
                    openDate: date(for: $0.commonSettings.openDate),
                    ownerId: $0.commonSettings.ownerId,
                    branchId: $0.commonSettings.branchId,
                    allowCredit: $0.commonSettings.allowCredit,
                    allowDebit: $0.commonSettings.allowDebit,
                    extraLargeDesign: SVGImageData(description: $0.commonSettings.xlDesignMd5Hash),
                    largeDesign: SVGImageData(description: $0.commonSettings.largeDesignMd5Hash),
                    mediumDesign: SVGImageData(description: $0.commonSettings.mediumDesignMd5Hash),
                    smallDesign: SVGImageData(description: $0.commonSettings.smallDesignMd5Hash),
                    fontDesignColor: ColorData(description: $0.commonSettings.fontDesignColor),
                    background: $0.commonSettings.background.map { ColorData(description: $0) },
                    externalId: accountSettingsDTO.externalID,
                    name: accountSettingsDTO.name,
                    dateOpen: Date.dateUTC(with: accountSettingsDTO.dateOpen),
                    status: .init(status: accountSettingsDTO.status),
                    branchName: accountSettingsDTO.branchName,
                    miniStatement: accountSettingsDTO.miniStatement.map { .init(paymentDataItem: $0) },
                    order: $0.commonSettings.order,
                    visibility: $0.commonSettings.visibility,
                    smallDesignMd5hash: $0.commonSettings.smallDesignMd5Hash,
                    smallBackgroundDesignHash: $0.commonSettings.smallBackgroundDesignHash,
                    detailedRatesUrl: accountSettingsDTO.detailedRatesUrl,
                    detailedConditionUrl: accountSettingsDTO.detailedConditionUrl)
            }
        }
        return ProductList(serial: serial ?? "", productList: productList)
    }
    
    // MARK: - Helpers
    
    private static func date(for date: Int?) -> Date? {
        
        guard let date else { return nil }
        
        return Date.dateUTC(with: date)
    }
}

private extension ProductType {
    
    init(productType: ProductListData.ProductType) {
        
        switch productType {
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
    
    init(status: ProductListData.Status) {
        
        switch status {
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

private extension ProductCardData.PaymentDataItem {
    
    init(paymentDataItem: ProductListData.Payment) {
        
        self.init(
            account: paymentDataItem.account,
            date: Date.dateUTC(with:paymentDataItem.date),
            amount: paymentDataItem.amount,
            currency: paymentDataItem.currency,
            purpose: paymentDataItem.purpose
        )
    }
}

private extension PaymentData {
    
    convenience init(paymentDataItem: ProductListData.Payment) {
        
        self.init(
            date: Date.dateUTC(with:paymentDataItem.date),
            account: paymentDataItem.account,
            currency: paymentDataItem.currency,
            amount: paymentDataItem.amount,
            purpose: paymentDataItem.purpose
        )
    }
}

private extension ProductCardData.LoanBaseParamInfoData {
    
    init?(loan: ProductListData.LoanBaseParam?) {
        
        guard let loan else { return nil }
        
        self.init(
            loanId: loan.loanID,
            clientId: loan.clientID,
            number: loan.number,
            currencyId: loan.currencyID,
            currencyNumber: loan.currencyNumber,
            currencyCode: loan.currencyCode,
            minimumPayment: loan.minimumPayment,
            gracePeriodPayment: loan.gracePeriodPayment,
            overduePayment: loan.overduePayment,
            availableExceedLimit: loan.availableExceedLimit,
            ownFunds: loan.ownFunds,
            debtAmount: loan.debtAmount,
            totalAvailableAmount: loan.totalAvailableAmount,
            totalDebtAmount: loan.totalDebtAmount
        )
    }
}

private extension ProductData.StatusPC {
    
    init(statusPC: ProductListData.StatusPC) {
        
        switch statusPC {
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

private extension ProductCardData.StatusCard {
    
    init(statusCard: ProductListData.StatusCard) {
        
        switch statusCard {
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

private extension ProductCardData.CardType {
    
    init(cardType: ProductListData.CardType) {
        
        switch cardType {
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
