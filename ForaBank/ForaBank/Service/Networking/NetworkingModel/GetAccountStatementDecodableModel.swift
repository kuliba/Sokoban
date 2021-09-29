//
//  GetAccountStatementDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 29.09.2021.
//

import Foundation

// MARK: - GetAccountStatementDecodableModel
struct GetAccountStatementDecodableModel: Codable, NetworkModelProtocol {
    let data: GetAccountStatementDataClass?
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
        data: GetAccountStatementDataClass?? = nil,
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

// MARK: - GetAccountStatementDataClass
struct GetAccountStatementDataClass: Codable {
    let accountID: Int?
    let accountNumber: String?
    let balance, balanceCUR, balanceIn, balanceInCUR: Int?
    let balanceOut, balanceOutCUR: Int?
    let endDate: EndDateClass?
    let flowCredit, flowCreditCUR, flowDebit, flowDebitCUR: Int?
    let startDate: EndDateClass?
    let statementEntryList: [StatementEntryList]?
    let subsystem: String?
}

// MARK: DataClass convenience initializers and mutators

extension GetAccountStatementDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAccountStatementDataClass.self, from: data)
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
        accountID: Int?? = nil,
        accountNumber: String?? = nil,
        balance: Int?? = nil,
        balanceCUR: Int?? = nil,
        balanceIn: Int?? = nil,
        balanceInCUR: Int?? = nil,
        balanceOut: Int?? = nil,
        balanceOutCUR: Int?? = nil,
        endDate: EndDateClass?? = nil,
        flowCredit: Int?? = nil,
        flowCreditCUR: Int?? = nil,
        flowDebit: Int?? = nil,
        flowDebitCUR: Int?? = nil,
        startDate: EndDateClass?? = nil,
        statementEntryList: [StatementEntryList]?? = nil,
        subsystem: String?? = nil
    ) -> GetAccountStatementDataClass {
        return GetAccountStatementDataClass(
            accountID: accountID ?? self.accountID,
            accountNumber: accountNumber ?? self.accountNumber,
            balance: balance ?? self.balance,
            balanceCUR: balanceCUR ?? self.balanceCUR,
            balanceIn: balanceIn ?? self.balanceIn,
            balanceInCUR: balanceInCUR ?? self.balanceInCUR,
            balanceOut: balanceOut ?? self.balanceOut,
            balanceOutCUR: balanceOutCUR ?? self.balanceOutCUR,
            endDate: endDate ?? self.endDate,
            flowCredit: flowCredit ?? self.flowCredit,
            flowCreditCUR: flowCreditCUR ?? self.flowCreditCUR,
            flowDebit: flowDebit ?? self.flowDebit,
            flowDebitCUR: flowDebitCUR ?? self.flowDebitCUR,
            startDate: startDate ?? self.startDate,
            statementEntryList: statementEntryList ?? self.statementEntryList,
            subsystem: subsystem ?? self.subsystem
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - EndDateClass
struct EndDateClass: Codable {
    let day, eon, eonAndYear, fractionalSecond: Int?
    let hour, millisecond, minute, month: Int?
    let second, timezone: Int?
    let valid: Bool?
    let xmlschemaType: XmlschemaType?
    let year: Int?
}

// MARK: EndDateClass convenience initializers and mutators

extension EndDateClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(EndDateClass.self, from: data)
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
        day: Int?? = nil,
        eon: Int?? = nil,
        eonAndYear: Int?? = nil,
        fractionalSecond: Int?? = nil,
        hour: Int?? = nil,
        millisecond: Int?? = nil,
        minute: Int?? = nil,
        month: Int?? = nil,
        second: Int?? = nil,
        timezone: Int?? = nil,
        valid: Bool?? = nil,
        xmlschemaType: XmlschemaType?? = nil,
        year: Int?? = nil
    ) -> EndDateClass {
        return EndDateClass(
            day: day ?? self.day,
            eon: eon ?? self.eon,
            eonAndYear: eonAndYear ?? self.eonAndYear,
            fractionalSecond: fractionalSecond ?? self.fractionalSecond,
            hour: hour ?? self.hour,
            millisecond: millisecond ?? self.millisecond,
            minute: minute ?? self.minute,
            month: month ?? self.month,
            second: second ?? self.second,
            timezone: timezone ?? self.timezone,
            valid: valid ?? self.valid,
            xmlschemaType: xmlschemaType ?? self.xmlschemaType,
            year: year ?? self.year
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - XmlschemaType
struct XmlschemaType: Codable {
    let localPart, namespaceURI, xmlschemaTypePrefix: String?

    enum CodingKeys: String, CodingKey {
        case localPart, namespaceURI
        case xmlschemaTypePrefix = "prefix"
    }
}

// MARK: XmlschemaType convenience initializers and mutators

extension XmlschemaType {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(XmlschemaType.self, from: data)
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
        localPart: String?? = nil,
        namespaceURI: String?? = nil,
        xmlschemaTypePrefix: String?? = nil
    ) -> XmlschemaType {
        return XmlschemaType(
            localPart: localPart ?? self.localPart,
            namespaceURI: namespaceURI ?? self.namespaceURI,
            xmlschemaTypePrefix: xmlschemaTypePrefix ?? self.xmlschemaTypePrefix
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - StatementEntryList
struct StatementEntryList: Codable {
    let accountID: Int?
    let accountNumber: String?
    let amount: Int?
    let auditDate: EndDateClass?
    let comment: String?
    let documentID: Int?
    let fastPayment: FastPayment_1?
    let operationDate: EndDateClass?
    let operationType: String?
}

// MARK: StatementEntryList convenience initializers and mutators

extension StatementEntryList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(StatementEntryList.self, from: data)
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
        accountID: Int?? = nil,
        accountNumber: String?? = nil,
        amount: Int?? = nil,
        auditDate: EndDateClass?? = nil,
        comment: String?? = nil,
        documentID: Int?? = nil,
        fastPayment: FastPayment_1?? = nil,
        operationDate: EndDateClass?? = nil,
        operationType: String?? = nil
    ) -> StatementEntryList {
        return StatementEntryList(
            accountID: accountID ?? self.accountID,
            accountNumber: accountNumber ?? self.accountNumber,
            amount: amount ?? self.amount,
            auditDate: auditDate ?? self.auditDate,
            comment: comment ?? self.comment,
            documentID: documentID ?? self.documentID,
            fastPayment: fastPayment ?? self.fastPayment,
            operationDate: operationDate ?? self.operationDate,
            operationType: operationType ?? self.operationType
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - FastPayment_1
struct FastPayment_1: Codable {
    let documentComment, foreignBankBIC, foreignBankID, foreignBankName: String?
    let foreignName, foreignPhoneNumber, opkcid: String?
}

// MARK: FastPayment_1 convenience initializers and mutators

extension FastPayment_1 {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FastPayment_1.self, from: data)
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
        documentComment: String?? = nil,
        foreignBankBIC: String?? = nil,
        foreignBankID: String?? = nil,
        foreignBankName: String?? = nil,
        foreignName: String?? = nil,
        foreignPhoneNumber: String?? = nil,
        opkcid: String?? = nil
    ) -> FastPayment_1 {
        return FastPayment_1(
            documentComment: documentComment ?? self.documentComment,
            foreignBankBIC: foreignBankBIC ?? self.foreignBankBIC,
            foreignBankID: foreignBankID ?? self.foreignBankID,
            foreignBankName: foreignBankName ?? self.foreignBankName,
            foreignName: foreignName ?? self.foreignName,
            foreignPhoneNumber: foreignPhoneNumber ?? self.foreignPhoneNumber,
            opkcid: opkcid ?? self.opkcid
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
