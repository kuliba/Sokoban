//
//  GetProductListDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getProductListDecodableModel = try GetProductListDecodableModel(json)

import Foundation

// MARK: - GetProductListDecodableModel
struct GetProductListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetProductListDatum]?
}

// MARK: GetProductListDecodableModel convenience initializers and mutators

extension GetProductListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetProductListDecodableModel.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        statusCode: Int?? = nil,
        errorMessage: String?? = nil,
        data: [GetProductListDatum]?? = nil
    ) -> GetProductListDecodableModel {
        return GetProductListDecodableModel(
            statusCode: statusCode ?? self.statusCode,
            errorMessage: errorMessage ?? self.errorMessage,
            data: data ?? self.data
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Datum.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let datum = try Datum(json)

struct ProductList {
    static var shared = ProductList()
    var productList: [GetProductListDatum]?
    
    private init() { }
}

// MARK: - GetProductListDatum
struct GetProductListDatum: Codable{
    let number, numberMasked: String?
    let balance: Double?
    let currency, productType, productName: String?
    let ownerID: Int?
    let loanID: Int?
    let accountNumber: String?
    let allowDebit, allowCredit: Bool?
    var customName: String?
    var cardID: Int?
    let accountID: Int?
    let name: String?
    let validThru: Int?
    let status, holderName, product, branch: String?
    let miniStatement: [PaymentData]?
    let mainField, additionalField, smallDesign, mediumDesign, largeDesign, paymentSystemName, paymentSystemImage, fontDesignColor: String?
    let id: Int?
    let background: [String?]
    let XLDesign: String?
    let statusPC: String?
    let interestRate: Float?
    let openDate: Int?
    let endDate: Int?
    let endDate_nf: Bool?
    let branchId: Int?
    let expireDate: String?
    let depositProductID: Int?
    let depositID: Int?
    let creditMinimumAmount: Double?
    let minimumBalance: Double?
    let balanceRUB: Double?
    let amount: Double?
    let clientID: Int?
    let currencyCode: String?
    let currencyNumber: Int?
    let bankProductID: Int?
    let finOperBrief: String?
    let currentInterestRate: Double?
    let principalDebt: Double?
    let defaultPrincipalDebt: Double?
    let totalAmountDebt: Double?
    let principalDebtAccount: String?
    let settlementAccount: String?
    let settlementAccountId: Int?
    let dateLong: Int?
    let loanBaseParam: LoanBaseParam?
    
    let smallDesignMd5Hash: String?
    let mediumDesignMd5Hash: String?
    let largeDesignMd5Hash: String?
    let paymentSystemImageMd5Hash: String?
    
    struct LoanBaseParam: Codable, Equatable {
        
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
    let isMain: Bool?
}

// MARK: GetProductListDatum convenience initializers and mutators

extension GetProductListDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetProductListDatum.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        number: String?? = nil,
        numberMasked: String?? = nil,
        balance: Double?? = nil,
        currency: String?? = nil,
        productType: String?? = nil,
        productName: String?? = nil,
        ownerID: Int?? = nil,
        loanID: Int?? = nil,
        accountNumber: String?? = nil,
        allowDebit: Bool?? = nil,
        allowCredit: Bool?? = nil,
        customName: String?? = nil,
        cardID: Int?? = nil,
        accountID: Int?? = nil,
        name: String?? = nil,
        validThru: Int?? = nil,
        status: String?? = nil,
        holderName: String?? = nil,
        product: String?? = nil,
        branch: String?? = nil,
        miniStatement: [PaymentData]?? = nil,
        mainField: String?? = nil,
        additionalField: String?? = nil,
        smallDesign: String?? = nil,
        mediumDesign: String?? = nil,
        largeDesign: String?? = nil,
        paymentSystemName: String?? = nil,
        paymentSystemImage: String?? = nil,
        fontDesignColor: String?? = nil,
        id: Int?? = nil,
        background: [String]?? = nil,
        XLDesign: String?? = nil,
        statusPC: String?? = nil,
        interestRate: Float? = nil,
        openDate: Int?? = nil,
        endDate: Int?? = nil,
        endDate_nf: Bool?? = nil,
        branchId: Int?? = nil,
        expireDate: String?? = nil,
        depositProductID: Int?? = nil,
        depositID: Int?? = nil,
        creditMinimumAmount: Double?? = nil,
        minimumBalance: Double?? = nil,
        balanceRUB: Double?? = 0.0,
        amount: Double?? = nil,
        clientID: Int?? = nil,
        currencyCode: String?? = nil,
        currencyNumber: Int?? = nil,
        bankProductID: Int?? = nil,
        finOperBrief: String?? = nil,
        currentInterestRate: Double?? = nil,
        principalDebt: Double?? = nil,
        defaultPrincipalDebt: Double?? = nil,
        totalAmountDebt: Double?? = nil,
        principalDebtAccount: String?? = nil,
        settlementAccount: String?? = nil,
        settlementAccountId: Int?? = nil,
        dateLong: Int?? = nil,
        loanBaseParam: LoanBaseParam?? = nil,
        isMain: Bool?? = true,
        smallDesignMd5Hash: String?,
        mediumDesignMd5Hash: String?,
        largeDesignMd5Hash: String?,
        paymentSystemImageMd5Hash: String?
    ) -> GetProductListDatum {
        return GetProductListDatum (
            number: number ?? self.number,
            numberMasked: numberMasked ?? self.numberMasked,
            balance: balance ?? self.balance,
            currency: currency ?? self.currency,
            productType: productType ?? self.productType,
            productName: productName ?? self.productName,
            ownerID: ownerID ?? self.ownerID,
            loanID: loanID ?? self.loanID,
            accountNumber: accountNumber ?? self.accountNumber,
            allowDebit: allowDebit ?? self.allowDebit,
            allowCredit: allowCredit ?? self.allowCredit,
            customName: customName ?? self.customName,
            cardID: cardID ?? self.cardID,
            accountID: accountID ?? self.accountID,
            name: name ?? self.name,
            validThru: validThru ?? self.validThru,
            status: status ?? self.status,
            holderName: holderName ?? self.holderName,
            product: product ?? self.product,
            branch: branch ?? self.branch,
            miniStatement: miniStatement ?? self.miniStatement,
            mainField: mainField ?? self.mainField,
            additionalField: additionalField ?? self.additionalField,
            smallDesign: smallDesign ?? self.smallDesign,
            mediumDesign: mediumDesign ?? self.mediumDesign,
            largeDesign: largeDesign ?? self.largeDesign,
            paymentSystemName: paymentSystemName ?? self.paymentSystemName,
            paymentSystemImage: paymentSystemImage ?? self.paymentSystemImage,
            fontDesignColor: fontDesignColor ?? self.fontDesignColor,
            id: id ?? self.id,
            background: (background ?? []) ?? self.background,
            XLDesign: XLDesign ?? self.XLDesign,
            statusPC: statusPC ?? self.statusPC,
            interestRate: interestRate ?? self.interestRate,
            openDate: openDate ?? self.openDate,
            endDate: endDate ?? self.endDate,
            endDate_nf: endDate_nf ?? self.endDate_nf,
            branchId: branchId ?? self.branchId,
            expireDate: expireDate ?? self.expireDate,
            depositProductID: depositProductID ?? self.depositProductID,
            depositID: depositID ?? self.depositID,
            creditMinimumAmount: creditMinimumAmount ?? self.creditMinimumAmount,
            minimumBalance: minimumBalance ?? self.minimumBalance,
            balanceRUB: balanceRUB ?? self.balanceRUB,
            amount: amount ?? self.amount,
            clientID: clientID ?? self.clientID,
            currencyCode: currencyCode ?? self.currencyCode,
            currencyNumber: currencyNumber ?? self.currencyNumber,
            bankProductID: bankProductID ?? self.bankProductID,
            finOperBrief: finOperBrief ?? self.finOperBrief,
            currentInterestRate: currentInterestRate ?? self.currentInterestRate,
            principalDebt: principalDebt ?? self.principalDebt,
            defaultPrincipalDebt: defaultPrincipalDebt ??  self.defaultPrincipalDebt,
            totalAmountDebt: totalAmountDebt ?? self.totalAmountDebt,
            principalDebtAccount: principalDebtAccount ?? self.principalDebtAccount,
            settlementAccount: settlementAccount ?? self.settlementAccount,
            settlementAccountId: settlementAccountId ?? self.settlementAccountId,
            dateLong: dateLong ?? self.dateLong,
            loanBaseParam: loanBaseParam ?? self.loanBaseParam,
            smallDesignMd5Hash: smallDesignMd5Hash ?? self.smallDesignMd5Hash,
            mediumDesignMd5Hash: mediumDesignMd5Hash ?? self.mediumDesignMd5Hash,
            largeDesignMd5Hash: largeDesignMd5Hash ?? self.largeDesignMd5Hash,
            paymentSystemImageMd5Hash: paymentSystemImageMd5Hash ?? self.paymentSystemImageMd5Hash,
            isMain: isMain ?? self.isMain
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
