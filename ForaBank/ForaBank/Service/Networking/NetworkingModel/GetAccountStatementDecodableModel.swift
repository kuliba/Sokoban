//
//  GetAccountStatementDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 29.09.2021.
//

import Foundation

// MARK: - GetAccountStatementDecodableModel
struct GetAccountStatementDecodableModel: Codable, NetworkModelProtocol{
    let data: [GetAccountStatementDatum]?
    let errorMessage: String?
    let statusCode: Int?
}

// MARK: GetAccountStatementDecodableModel convenience initializers and mutators

extension GetAccountStatementDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAccountStatementDecodableModel.self, from: data)
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
        data: [GetAccountStatementDatum]?? = nil,
        errorMessage: String?? = nil,
        statusCode: Int?? = nil
    ) -> GetAccountStatementDecodableModel {
        return GetAccountStatementDecodableModel(
            data: data ?? self.data,
            errorMessage: errorMessage ?? self.errorMessage,
            statusCode: statusCode ?? self.statusCode
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - GetAccountStatementDatum
struct GetAccountStatementDatum: Codable {
    let mcc, accountID: Int?
    let accountNumber: String?
    let amount: Float?
    let comment: String?
    let currencyCodeNumeric: Int?
    let date: Int?
    let documentID: Int?
    let groupName, md5Hash, merchantName, merchantNameRus: String?
    let name, operationType, svgImage: String?
    let tranDate: Int?
    let type: String?
    var dateFormatting: String?
    
    enum CodingKeys: String, CodingKey {
        case mcc = "MCC"
        case accountID, accountNumber, amount, comment, currencyCodeNumeric, date, documentID, groupName
        case md5Hash = "md5hash"
        case merchantName, merchantNameRus, name, operationType, svgImage, tranDate, type, dateFormatting
    }
}

//FIXME: refactor model as soon as possible!!!
extension GetAccountStatementDatum {
    
    var operationTypeEnum: OperationType {
        
        guard let operationType = operationType, let operationTypeEnum = OperationType(rawValue: operationType) else {
            
            //FIXME: dirty hack for refactoring period!!!
            return .debit
        }
        
        return operationTypeEnum
    }
    
    var operationEnv: OperationEnvironment {
        
        guard let type = type, let operationEnv = OperationEnvironment(rawValue: type) else {
            
            //FIXME: dirty hack for refactoring period!!!
            return .inside
        }
        
        return operationEnv
    }
    
    var transactionDate: Date {
        
        Date(timeIntervalSince1970: TimeInterval((date ?? 0) / 1000))
    }
}

// MARK: GetAccountStatementDatum convenience initializers and mutators

extension GetAccountStatementDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAccountStatementDatum.self, from: data)
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
        mcc: Int?? = nil,
        accountID: Int?? = nil,
        accountNumber: String?? = nil,
        amount: Float?? = nil,
        comment: String?? = nil,
        currencyCodeNumeric: Int?? = nil,
        date: Int?? = nil,
        documentID: Int?? = nil,
        groupName: String?? = nil,
        md5Hash: String?? = nil,
        merchantName: String?? = nil,
        merchantNameRus: String?? = nil,
        name: String?? = nil,
        operationType: String?? = nil,
        svgImage: String?? = nil,
        tranDate: Int?? = nil,
        type: String?? = nil,
        dateFormatting: String?? = nil
    ) -> GetAccountStatementDatum {
        return GetAccountStatementDatum(
            mcc: mcc ?? self.mcc,
            accountID: accountID ?? self.accountID,
            accountNumber: accountNumber ?? self.accountNumber,
            amount: amount ?? self.amount,
            comment: comment ?? self.comment,
            currencyCodeNumeric: currencyCodeNumeric ?? self.currencyCodeNumeric,
            date: date ?? self.date,
            documentID: documentID ?? self.documentID,
            groupName: groupName ?? self.groupName,
            md5Hash: md5Hash ?? self.md5Hash,
            merchantName: merchantName ?? self.merchantName,
            merchantNameRus: merchantNameRus ?? self.merchantNameRus,
            name: name ?? self.name,
            operationType: operationType ?? self.operationType,
            svgImage: svgImage ?? self.svgImage,
            tranDate: tranDate ?? self.tranDate,
            type: type ?? self.type,
            dateFormatting: dateFormatting ?? self.dateFormatting
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
