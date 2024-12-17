//
//  ProductData+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 30.05.2022.
//

import Foundation


extension ProductData {
    
    func getProductListDatum() -> GetProductListDatum {
        
        let productListDatum: GetProductListDatum
        
        switch self {
        case let card as ProductCardData:
            
            productListDatum = .init(number: number,
                                     numberMasked: numberMasked,
                                     balance: balance,
                                     currency: currency,
                                     productType: productType.rawValue,
                                     productName: productName,
                                     ownerID: ownerId,
                                     loanID: nil,
                                     accountNumber: accountNumber,
                                     allowDebit: allowDebit,
                                     allowCredit: allowCredit,
                                     customName: customName,
                                     cardID: id,
                                     accountID: card.accountId,
                                     name: card.name,
                                     validThru: Int(card.validThru.timeIntervalSince1970),
                                     status: card.status.rawValue,
                                     holderName: card.holderName,
                                     product: card.product,
                                     branch: card.branch,
                                     miniStatement: nil,
                                     mainField: mainField,
                                     additionalField: additionalField,
                                     smallDesign: smallDesign.description,
                                     mediumDesign: mediumDesign.description,
                                     largeDesign: largeDesign.description,
                                     paymentSystemName: card.paymentSystemName,
                                     paymentSystemImage: card.paymentSystemImage?.description,
                                     fontDesignColor: fontDesignColor.description,
                                     id: id,
                                     background: background.map { $0.description },
                                     XLDesign: nil,
                                     statusPC: card.statusPc?.rawValue,
                                     interestRate: nil,
                                     openDate: nil,
                                     endDate: nil,
                                     endDate_nf: nil,
                                     branchId: branchId,
                                     expireDate: card.expireDate,
                                     depositProductID: nil,
                                     depositID: nil,
                                     creditMinimumAmount: nil,
                                     minimumBalance: nil,
                                     balanceRUB: balanceRub,
                                     amount: nil,
                                     clientID: nil,
                                     currencyCode: nil,
                                     currencyNumber: nil,
                                     bankProductID: nil,
                                     finOperBrief: nil,
                                     currentInterestRate: nil,
                                     principalDebt: nil,
                                     defaultPrincipalDebt: nil,
                                     totalAmountDebt: nil,
                                     principalDebtAccount: nil,
                                     settlementAccount: nil,
                                     settlementAccountId: nil,
                                     dateLong: nil,
                                     loanBaseParam: card.loanBaseParam?.loanBaseParam(),
                                     smallDesignMd5Hash: card.smallDesignMd5hash,
                                     mediumDesignMd5Hash: card.mediumDesignMd5Hash,
                                     largeDesignMd5Hash: card.largeDesignMd5Hash,
                                     paymentSystemImageMd5Hash: card.paymentSystemImageMd5Hash,
                                     cardType: card.cardType?.cardTypeLegacy,
                                     isMain: card.isMain
            )
        case let account as ProductAccountData:
              
            productListDatum = .init(number: number,
                                     numberMasked: numberMasked,
                                     balance: balance,
                                     currency: currency,
                                     productType: productType.rawValue,
                                     productName: productName,
                                     ownerID: ownerId,
                                     loanID: nil,
                                     accountNumber: accountNumber,
                                     allowDebit: allowDebit,
                                     allowCredit: allowCredit,
                                     customName: customName,
                                     cardID: nil,
                                     accountID: nil,
                                     name: account.name,
                                     validThru: nil,
                                     status: account.status.rawValue,
                                     holderName: nil,
                                     product: nil,
                                     branch: account.branchName,
                                     miniStatement: account.miniStatement,
                                     mainField: mainField,
                                     additionalField: additionalField,
                                     smallDesign: smallDesign.description,
                                     mediumDesign: mediumDesign.description,
                                     largeDesign: largeDesign.description,
                                     paymentSystemName: nil,
                                     paymentSystemImage: nil,
                                     fontDesignColor: fontDesignColor.description,
                                     id: id,
                                     background: background.map { $0.description },
                                     XLDesign: nil,
                                     statusPC: nil,
                                     interestRate: nil,
                                     openDate: Int(account.dateOpen.timeIntervalSince1970),
                                     endDate: nil,
                                     endDate_nf: nil,
                                     branchId: branchId,
                                     expireDate: nil,
                                     depositProductID: nil,
                                     depositID: nil,
                                     creditMinimumAmount: nil,
                                     minimumBalance: nil,
                                     balanceRUB: balanceRub,
                                     amount: nil,
                                     clientID: nil,
                                     currencyCode: nil,
                                     currencyNumber: nil,
                                     bankProductID: nil,
                                     finOperBrief: nil,
                                     currentInterestRate: nil,
                                     principalDebt: nil,
                                     defaultPrincipalDebt: nil,
                                     totalAmountDebt: nil,
                                     principalDebtAccount: nil,
                                     settlementAccount: nil,
                                     settlementAccountId: nil,
                                     dateLong: nil,
                                     loanBaseParam: nil,
                                     smallDesignMd5Hash: account.smallDesignMd5hash,
                                     mediumDesignMd5Hash: account.mediumDesignMd5Hash,
                                     largeDesignMd5Hash: account.largeDesignMd5Hash,
                                     paymentSystemImageMd5Hash: nil,
                                     cardType: nil,
                                     isMain: nil
            )

        case let deposit as ProductDepositData:
            
            productListDatum = .init(number: number,
                                     numberMasked: numberMasked,
                                     balance: balance,
                                     currency: currency,
                                     productType: productType.rawValue,
                                     productName: productName,
                                     ownerID: ownerId,
                                     loanID: nil,
                                     accountNumber: accountNumber,
                                     allowDebit: allowDebit,
                                     allowCredit: allowCredit,
                                     customName: customName,
                                     cardID: nil,
                                     accountID: deposit.accountId,
                                     name: nil,
                                     validThru: nil,
                                     status: nil,
                                     holderName: nil,
                                     product: nil,
                                     branch: nil,
                                     miniStatement: nil,
                                     mainField: mainField,
                                     additionalField: additionalField,
                                     smallDesign: smallDesign.description,
                                     mediumDesign: mediumDesign.description,
                                     largeDesign: largeDesign.description,
                                     paymentSystemName: nil,
                                     paymentSystemImage: nil,
                                     fontDesignColor: fontDesignColor.description,
                                     id: id,
                                     background: background.map { $0.description },
                                     XLDesign: nil,
                                     statusPC: nil,
                                     interestRate: Float(deposit.interestRate),
                                     openDate: nil,
                                     endDate: deposit.endDate != nil ? deposit.endDate!.secondsSince1970UTC : nil,
                                     endDate_nf: deposit.endDateNf,
                                     branchId: branchId,
                                     expireDate: nil,
                                     depositProductID: deposit.depositProductId,
                                     depositID: deposit.depositId,
                                     creditMinimumAmount: deposit.creditMinimumAmount,
                                     minimumBalance: deposit.minimumBalance,
                                     balanceRUB: balanceRub,
                                     amount: nil,
                                     clientID: nil,
                                     currencyCode: nil,
                                     currencyNumber: nil,
                                     bankProductID: nil,
                                     finOperBrief: nil,
                                     currentInterestRate: nil,
                                     principalDebt: nil,
                                     defaultPrincipalDebt: nil,
                                     totalAmountDebt: nil,
                                     principalDebtAccount: nil,
                                     settlementAccount: nil,
                                     settlementAccountId: nil,
                                     dateLong: nil,
                                     loanBaseParam: nil,
                                     smallDesignMd5Hash: deposit.smallDesignMd5hash,
                                     mediumDesignMd5Hash: deposit.mediumDesignMd5Hash,
                                     largeDesignMd5Hash: deposit.largeDesignMd5Hash,
                                     paymentSystemImageMd5Hash: nil,
                                     cardType: nil,
                                     isMain: nil
            )
        case let loan as ProductLoanData:
            
            productListDatum = .init(number: number,
                                     numberMasked: numberMasked,
                                     balance: balance,
                                     currency: currency,
                                     productType: productType.rawValue,
                                     productName: productName,
                                     ownerID: ownerId,
                                     loanID: nil,
                                     accountNumber: accountNumber,
                                     allowDebit: allowDebit,
                                     allowCredit: allowCredit,
                                     customName: customName,
                                     cardID: nil,
                                     accountID: nil,
                                     name: nil,
                                     validThru: nil,
                                     status: nil,
                                     holderName: nil,
                                     product: nil,
                                     branch: nil,
                                     miniStatement: nil,
                                     mainField: mainField,
                                     additionalField: additionalField,
                                     smallDesign: smallDesign.description,
                                     mediumDesign: mediumDesign.description,
                                     largeDesign: largeDesign.description,
                                     paymentSystemName: nil,
                                     paymentSystemImage: nil,
                                     fontDesignColor: fontDesignColor.description,
                                     id: id,
                                     background: background.map { $0.description },
                                     XLDesign: nil,
                                     statusPC: nil,
                                     interestRate: nil,
                                     openDate: nil,
                                     endDate: nil,
                                     endDate_nf: nil,
                                     branchId: branchId,
                                     expireDate: nil,
                                     depositProductID: nil,
                                     depositID: nil,
                                     creditMinimumAmount: nil,
                                     minimumBalance: nil,
                                     balanceRUB: balanceRub,
                                     amount: loan.amount,
                                     clientID: nil,
                                     currencyCode: nil,
                                     currencyNumber: loan.currencyNumber,
                                     bankProductID: loan.bankProductId,
                                     finOperBrief: nil,
                                     currentInterestRate: loan.currentInterestRate,
                                     principalDebt: loan.principalDebt,
                                     defaultPrincipalDebt: loan.defaultPrincipalDebt,
                                     totalAmountDebt: loan.totalAmountDebt,
                                     principalDebtAccount: loan.principalDebtAccount,
                                     settlementAccount: loan.settlementAccount,
                                     settlementAccountId: loan.settlementAccountId,
                                     dateLong: Int(loan.dateLong.timeIntervalSince1970),
                                     loanBaseParam: nil,
                                     smallDesignMd5Hash: loan.smallDesignMd5hash,
                                     mediumDesignMd5Hash: loan.mediumDesignMd5Hash,
                                     largeDesignMd5Hash: loan.largeDesignMd5Hash,
                                     paymentSystemImageMd5Hash: nil,
                                     cardType: nil,
                                     isMain: nil
)
        default:
            productListDatum = .init(number: number,
                                     numberMasked: numberMasked,
                                     balance: balance,
                                     currency: currency,
                                     productType: productType.rawValue,
                                     productName: productName,
                                     ownerID: ownerId,
                                     loanID: nil,
                                     accountNumber: accountNumber,
                                     allowDebit: allowDebit,
                                     allowCredit: allowCredit,
                                     customName: customName,
                                     cardID: nil,
                                     accountID: nil,
                                     name: nil,
                                     validThru: nil,
                                     status: nil,
                                     holderName: nil,
                                     product: nil,
                                     branch: nil,
                                     miniStatement: nil,
                                     mainField: mainField,
                                     additionalField: additionalField,
                                     smallDesign: smallDesign.description,
                                     mediumDesign: mediumDesign.description,
                                     largeDesign: largeDesign.description,
                                     paymentSystemName: nil,
                                     paymentSystemImage: nil,
                                     fontDesignColor: fontDesignColor.description,
                                     id: id,
                                     background: background.map { $0.description },
                                     XLDesign: nil,
                                     statusPC: nil,
                                     interestRate: nil,
                                     openDate: nil,
                                     endDate: nil,
                                     endDate_nf: nil,
                                     branchId: branchId,
                                     expireDate: nil,
                                     depositProductID: nil,
                                     depositID: nil,
                                     creditMinimumAmount: nil,
                                     minimumBalance: nil,
                                     balanceRUB: balanceRub,
                                     amount: nil,
                                     clientID: nil,
                                     currencyCode: nil,
                                     currencyNumber: nil,
                                     bankProductID: nil,
                                     finOperBrief: nil,
                                     currentInterestRate: nil,
                                     principalDebt: nil,
                                     defaultPrincipalDebt: nil,
                                     totalAmountDebt: nil,
                                     principalDebtAccount: nil,
                                     settlementAccount: nil,
                                     settlementAccountId: nil,
                                     dateLong: nil,
                                     loanBaseParam: nil,
                                     smallDesignMd5Hash: nil,
                                     mediumDesignMd5Hash: nil,
                                     largeDesignMd5Hash: nil,
                                     paymentSystemImageMd5Hash: nil,
                                     cardType: nil,
                                     isMain: nil)
        }
        
        return productListDatum
    }
    
    func userAllProducts() -> UserAllCardsModel {
        
        let userAllCardsModel: UserAllCardsModel = .init(with: getProductListDatum())
        return userAllCardsModel
    }
}

extension GetProductListDatum.LoanBaseParam {
    
    func loanBaseParam() -> ProductCardData.LoanBaseParamInfoData {
        
        return .init(loanId: loanID, clientId: clientID, number: number, currencyId: currencyID, currencyNumber: currencyNumber, currencyCode: currencyCode, minimumPayment: minimumPayment, gracePeriodPayment: gracePeriodPayment, overduePayment: overduePayment, availableExceedLimit: availableExceedLimit, ownFunds: ownFunds, debtAmount: debtAmount, totalAvailableAmount: totalAvailableAmount, totalDebtAmount: totalDebtAmount)
    }
}

extension ProductCardData.LoanBaseParamInfoData {
    
    func loanBaseParam() -> GetProductListDatum.LoanBaseParam    {
        
        return .init(loanID: loanId, clientID: clientId, number: number, currencyID: currencyId, currencyNumber: currencyNumber, currencyCode: currencyCode, minimumPayment: minimumPayment, gracePeriodPayment: gracePeriodPayment, overduePayment: overduePayment, availableExceedLimit: availableExceedLimit, ownFunds: ownFunds, debtAmount: debtAmount, totalAvailableAmount: totalAvailableAmount, totalDebtAmount: totalDebtAmount)
    }
}

extension ProductCardData.CardType {
    
    var cardTypeLegacy: CardType {
        switch self {
        case .main:
            return .main
        case .regular:
            return .regular
        case .additionalSelf:
            return .additionalSelf
        case .additionalSelfAccOwn:
            return .additionalSelfAccOwn
        case .additionalOther:
            return .additionalOther
        case .additionalCorporate:
            return .additionalCorporate
        case .corporate:
            return .corporate
        case .individualBusinessman:
            return .individualBusinessman
        case .individualBusinessmanMain:
            return .individualBusinessmanMain
        }
    }
}
