//
//  Services+getProductListByType.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.03.2024.
//

import Foundation
import GenericRemoteService
import GetProductListByTypeService

extension Services {
        
    typealias GetProductsResponse = ServerCommands.ProductController.GetProductListByType.Response.List
    
    typealias GetProductListByTypeResponse = GetProductListByTypeService.ProductResponse
    
    typealias GetProductListByTypeCompletion = (GetProductListByTypeResponse?) -> Void
    typealias GetProductListByType = (ProductType, @escaping GetProductListByTypeCompletion) -> Void

    static func getProductListByType(
        _ httpClient: HTTPClient,
        logger: LoggerAgentProtocol
    ) -> GetProductListByType {
        
        let infoNetworkLog = { logger.log(level: .info, category: .network, message: $0, file: $1, line: $2) }

        let loggingRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createGetProductListByTypeRequest,
            performRequest: httpClient.performRequest,
            mapResponse: GetProductListByTypeService.ResponseMapper.mapGetProductListByTypeResponse,
            log: infoNetworkLog
        ).remoteService
        
        return { productType, completion in
            
            loggingRemoteService.process(productType) { result in
                
                completion(try? result.get())
            }
        }
    }
    
    static func mapProductResponse(
        _ productResponse: ProductResponse
    ) -> GetProductsResponse {
        
        .init(
            serial: productResponse.serial ?? "",
            productList: productResponse.products.map {
                
                switch $0.uniqueProperties {
                case let .card(cardData):
                    return ProductCardData(
                        commonData: $0.commonProperties,
                        cardData: cardData
                    )
                    
                case let .loan(loanData):
                    return ProductLoanData(
                        commonData: $0.commonProperties,
                        loanData: loanData
                    )
                    
                case let .deposit(depositData):
                    return ProductDepositData(
                        commonData: $0.commonProperties,
                        depositData: depositData
                    )
                    
                case let .account(accountData):
                    return ProductAccountData(
                        commonData: $0.commonProperties,
                        accountData: accountData
                    )
                }
            }
        )
    }
}

private extension ProductCardData {
    
    convenience init(
        commonData: ProductResponse.CommonProperties,
        cardData: ProductResponse.Card
    ) {
        
        self.init(
            id: commonData.id,
            productType: .init(commonData.productType),
            number: commonData.number,
            numberMasked: commonData.numberMasked,
            accountNumber: commonData.accountNumber,
            balance: commonData.balance.map(Double.init),
            balanceRub: commonData.balanceRUB.map(Double.init),
            currency: commonData.currency,
            mainField: commonData.mainField,
            additionalField: commonData.additionalField,
            customName: commonData.customName,
            productName: commonData.productName,
            openDate: commonData.openDate.map { Date.dateUTC(with: $0) },
            ownerId: commonData.ownerId,
            branchId: commonData.branchId,
            allowCredit: commonData.allowCredit,
            allowDebit: commonData.allowDebit,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: commonData.fontDesignColor),
            background: commonData.background.map { .init(description: $0) },
            accountId: cardData.accountID,
            cardId: cardData.cardID,
            name: cardData.name,
            validThru: Date.dateUTC(with: cardData.validThru),
            status: .init(cardData.status),
            expireDate: cardData.expireDate,
            holderName: cardData.holderName,
            product: cardData.product,
            branch: cardData.branch,
            miniStatement: nil,
            paymentSystemName: cardData.paymentSystemName,
            paymentSystemImage: nil,
            loanBaseParam: cardData.loanBaseParam.map { .init(loan: $0) },
            statusPc: .init(cardData.statusPC),
            isMain: cardData.cardType == .main || cardData.cardType == .regular,
            externalId: nil,
            order: commonData.order,
            visibility: commonData.visibility,
            smallDesignMd5hash: commonData.smallDesignMd5Hash,
            smallBackgroundDesignHash: commonData.smallBackgroundDesignHash,
            mediumDesignMd5Hash: commonData.mediumDesignMd5Hash,
            largeDesignMd5Hash: commonData.largeDesignMd5Hash,
            xlDesignMd5Hash: commonData.xlDesignMd5Hash,
            statusCard: .init(cardData.statusCard),
            cardType: .init(cardData.cardType),
            idParent: cardData.idParent,
            paymentSystemImageMd5Hash: cardData.paymentSystemImageMd5Hash)
    }
}

private extension ProductLoanData {
    
    convenience init(
        commonData: ProductResponse.CommonProperties,
        loanData: ProductResponse.Loan
    ) {
        
        self.init(
            id: commonData.id,
            productType: .init(commonData.productType),
            number: commonData.number,
            numberMasked: commonData.numberMasked,
            accountNumber: commonData.accountNumber,
            balance: commonData.balance.map(Double.init),
            balanceRub: commonData.balanceRUB.map(Double.init),
            currency: commonData.currency,
            mainField: commonData.mainField,
            additionalField: commonData.additionalField,
            customName: commonData.customName,
            productName: commonData.productName,
            openDate: commonData.openDate.map { Date.dateUTC(with: $0) },
            ownerId: commonData.ownerId,
            branchId: commonData.branchId,
            allowCredit: commonData.allowCredit,
            allowDebit: commonData.allowDebit,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: commonData.fontDesignColor),
            background: commonData.background.map { .init(description: $0) },
            currencyNumber: loanData.currencyNumber,
            bankProductId: loanData.bankProductID,
            amount: Double(from: loanData.amount),
            currentInterestRate: loanData.currentInterestRate,
            principalDebt: loanData.principalDebt.map(Double.init),
            defaultPrincipalDebt: loanData.defaultPrincipalDebt.map(Double.init),
            totalAmountDebt: loanData.totalAmountDebt.map(Double.init),
            principalDebtAccount: loanData.principalDebtAccount,
            settlementAccount: loanData.settlementAccount,
            settlementAccountId: loanData.settlementAccountId,
            dateLong: Date.dateUTC(with: loanData.dateLong),
            strDateLong: loanData.strDateLong,
            order: commonData.order,
            visibility: commonData.visibility,
            smallDesignMd5hash: commonData.smallDesignMd5Hash,
            smallBackgroundDesignHash: commonData.smallBackgroundDesignHash,
            mediumDesignMd5Hash: commonData.mediumDesignMd5Hash,
            largeDesignMd5Hash: commonData.largeDesignMd5Hash,
            xlDesignMd5Hash: commonData.xlDesignMd5Hash)
    }
}

private extension ProductDepositData {
    
    convenience init(
        commonData: ProductResponse.CommonProperties,
        depositData: ProductResponse.Deposit
    ) {
        
        self.init(
            id: commonData.id,
            productType: .init(commonData.productType),
            number: commonData.number,
            numberMasked: commonData.numberMasked,
            accountNumber: commonData.accountNumber,
            balance: commonData.balance.map(Double.init),
            balanceRub: commonData.balanceRUB.map(Double.init),
            currency: commonData.currency,
            mainField: commonData.mainField,
            additionalField: commonData.additionalField,
            customName: commonData.customName,
            productName: commonData.productName,
            openDate: commonData.openDate.map { Date.dateUTC(with: $0) },
            ownerId: commonData.ownerId,
            branchId: commonData.branchId,
            allowCredit: commonData.allowCredit,
            allowDebit: commonData.allowDebit,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: commonData.fontDesignColor),
            background: commonData.background.map { .init(description: $0) },
            depositProductId: depositData.depositProductID,
            depositId: depositData.depositID,
            interestRate: depositData.interestRate,
            accountId: depositData.accountID,
            creditMinimumAmount: depositData.creditMinimumAmount.map(Double.init) ?? 0,
            minimumBalance: Double(from: depositData.minimumBalance),
            endDate: depositData.endDate.map { Date.dateUTC(with: $0) },
            endDateNf: depositData.endDateNF,
            isDemandDeposit: depositData.demandDeposit,
            isDebitInterestAvailable: depositData.isDebitInterestAvailable,
            order: commonData.order,
            visibility: commonData.visibility,
            smallDesignMd5hash: commonData.smallDesignMd5Hash,
            smallBackgroundDesignHash: commonData.smallBackgroundDesignHash,
            mediumDesignMd5Hash: commonData.mediumDesignMd5Hash,
            largeDesignMd5Hash: commonData.largeDesignMd5Hash,
            xlDesignMd5Hash: commonData.xlDesignMd5Hash)
    }
}

private extension ProductAccountData {
    
    convenience init(
        commonData: ProductResponse.CommonProperties,
        accountData: ProductResponse.Account
    ) {
        
        self.init(
            id: commonData.id,
            productType: .init(commonData.productType),
            number: commonData.number,
            numberMasked: commonData.numberMasked,
            accountNumber: commonData.accountNumber,
            balance: commonData.balance.map(Double.init),
            balanceRub: commonData.balanceRUB.map(Double.init),
            currency: commonData.currency,
            mainField: commonData.mainField,
            additionalField: commonData.additionalField,
            customName: commonData.customName,
            productName: commonData.productName,
            openDate: commonData.openDate.map { Date.dateUTC(with: $0) },
            ownerId: commonData.ownerId,
            branchId: commonData.branchId,
            allowCredit: commonData.allowCredit,
            allowDebit: commonData.allowDebit,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: commonData.fontDesignColor),
            background: commonData.background.map { .init(description: $0) },
            externalId: accountData.externalID,
            name: accountData.name,
            dateOpen: Date.dateUTC(with: accountData.dateOpen),
            status: .init(accountData.status),
            branchName: accountData.branchName,
            miniStatement: [],
            order: commonData.order,
            visibility: commonData.visibility,
            smallDesignMd5hash: commonData.smallDesignMd5Hash,
            smallBackgroundDesignHash: commonData.smallBackgroundDesignHash,
            detailedRatesUrl: accountData.detailedRatesUrl,
            detailedConditionUrl: accountData.detailedConditionUrl,
            mediumDesignMd5Hash: commonData.mediumDesignMd5Hash,
            largeDesignMd5Hash: commonData.largeDesignMd5Hash,
            xlDesignMd5Hash: commonData.xlDesignMd5Hash)
    }
}

private extension ProductType {
    
    init(_ productType: ProductResponse.ProductType) {
        
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
    
    init(_ status: ProductResponse.Status) {
        
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
            
        case .notActivated:
            self = .notActivated
            
        case .blockedUnlockAvailable:
            self = .blockedUnlockAvailable
        }
    }
}

private extension ProductCardData.LoanBaseParamInfoData {
    
    init(loan: ProductResponse.LoanBaseParam) {
                
        self.init(
            loanId: loan.loanID,
            clientId: loan.clientID,
            number: loan.number,
            currencyId: loan.currencyID,
            currencyNumber: loan.currencyNumber,
            currencyCode: loan.currencyCode,
            minimumPayment: loan.minimumPayment.map(Double.init),
            gracePeriodPayment: loan.gracePeriodPayment.map(Double.init),
            overduePayment: loan.overduePayment.map(Double.init),
            availableExceedLimit: loan.availableExceedLimit.map(Double.init),
            ownFunds: loan.ownFunds.map(Double.init),
            debtAmount: loan.debtAmount.map(Double.init),
            totalAvailableAmount: loan.totalAvailableAmount.map(Double.init),
            totalDebtAmount: loan.totalDebtAmount.map(Double.init)
        )
    }
}

private extension ProductData.StatusPC {
    
    init(_ statusPC: ProductResponse.StatusPC) {
        
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
        }
    }
}

private extension ProductCardData.StatusCard {
    
    init(_ statusCard: ProductResponse.StatusCard) {
        
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
    
    init(_ cardType: ProductResponse.CardType) {
        
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

private extension Double {
    
    init(from decimal: Decimal) {
        
        self.init(truncating: decimal as NSNumber)
    }
}
