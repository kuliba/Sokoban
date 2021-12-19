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
    let accountNumber: String?
    let allowDebit, allowCredit: Bool?
    var customName: String?
    var cardID: Int?
    let accountID: Int?
    let name: String?
    let validThru: Int?
    let status, holderName, product, branch: String?
    let miniStatement: [JSONAny]?
    let mainField, additionalField, smallDesign, mediumDesign, largeDesign, paymentSystemName, paymentSystemImage, fontDesignColor: String?
    let id: Int?
    let background: [String?]
    let XLDesign: String?
    let statusPC: String?
    let interestRate: Float?
    let openDate: Int?
    let branchId: Int?
    let expireDate: String?
    let depositProductID: Int?
    let depositID: Int?
    let creditMinimumAmount: Double?
    let minimumBalance: Double?
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
        miniStatement: [JSONAny]?? = nil,
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
        branchId: Int?? = nil,
        expireDate: String?? = nil,
        depositProductID: Int?? = nil,
        depositID: Int?? = nil,
        creditMinimumAmount: Double?? = nil,
        minimumBalance: Double?? = nil
        
    ) -> GetProductListDatum {
        return GetProductListDatum (
            number: number ?? self.number,
            numberMasked: numberMasked ?? self.numberMasked,
            balance: balance ?? self.balance,
            currency: currency ?? self.currency,
            productType: productType ?? self.productType,
            productName: productName ?? self.productName,
            ownerID: ownerID ?? self.ownerID,
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
            branchId: branchId ?? self.branchId,
            expireDate: expireDate ?? self.expireDate,
            depositProductID: depositProductID ?? self.depositProductID,
            depositID: depositID ?? self.depositID,
            creditMinimumAmount: creditMinimumAmount ?? self.creditMinimumAmount,
            minimumBalance: minimumBalance ?? self.minimumBalance
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
