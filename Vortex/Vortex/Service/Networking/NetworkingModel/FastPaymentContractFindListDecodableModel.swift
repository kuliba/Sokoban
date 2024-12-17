//
//  FastPaymentContractFindListDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.08.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fastPaymentContractFindListDecodableModel = try FastPaymentContractFindListDecodableModel(json)

import Foundation

// MARK: - FastPaymentContractFindListDecodableModel
struct FastPaymentContractFindListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [FastPaymentContractFindListDatum]?
}

// MARK: FastPaymentContractFindListDecodableModel convenience initializers and mutators

extension FastPaymentContractFindListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FastPaymentContractFindListDecodableModel.self, from: data)
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
        data: [FastPaymentContractFindListDatum]?? = nil
    ) -> FastPaymentContractFindListDecodableModel {
        return FastPaymentContractFindListDecodableModel(
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

// MARK: - FastPaymentContractFindListDatum
struct FastPaymentContractFindListDatum: Codable {
    let fastPaymentContractAccountAttributeList: [FastPaymentContractAccountAttributeList]?
    let fastPaymentContractAttributeList: [FastPaymentContractAttributeList]?
    let fastPaymentContractClAttributeList: [FastPaymentContractClAttributeList]?
}

// MARK: Datum convenience initializers and mutators

extension FastPaymentContractFindListDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FastPaymentContractFindListDatum.self, from: data)
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
        fastPaymentContractAccountAttributeList: [FastPaymentContractAccountAttributeList]?? = nil,
        fastPaymentContractAttributeList: [FastPaymentContractAttributeList]?? = nil,
        fastPaymentContractClAttributeList: [FastPaymentContractClAttributeList]?? = nil
    ) -> FastPaymentContractFindListDatum {
        return FastPaymentContractFindListDatum(
            fastPaymentContractAccountAttributeList: fastPaymentContractAccountAttributeList ?? self.fastPaymentContractAccountAttributeList,
            fastPaymentContractAttributeList: fastPaymentContractAttributeList ?? self.fastPaymentContractAttributeList,
            fastPaymentContractClAttributeList: fastPaymentContractClAttributeList ?? self.fastPaymentContractClAttributeList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - FastPaymentContractAccountAttributeList
struct FastPaymentContractAccountAttributeList: Codable {
    let accountID: Int?
    let flagPossibAddAccount: String?
    let maxAddAccount, minAddAccount: Int?
    let accountNumber: String?
}

// MARK: FastPaymentContractAccountAttributeList convenience initializers and mutators

extension FastPaymentContractAccountAttributeList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FastPaymentContractAccountAttributeList.self, from: data)
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
        flagPossibAddAccount: String?? = nil,
        maxAddAccount: Int?? = nil,
        minAddAccount: Int?? = nil,
        accountNumber: String?? = nil
    ) -> FastPaymentContractAccountAttributeList {
        return FastPaymentContractAccountAttributeList(
            accountID: accountID ?? self.accountID,
            flagPossibAddAccount: flagPossibAddAccount ?? self.flagPossibAddAccount,
            maxAddAccount: maxAddAccount ?? self.maxAddAccount,
            minAddAccount: minAddAccount ?? self.minAddAccount,
            accountNumber: accountNumber ?? self.accountNumber
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - FastPaymentContractAttributeList
struct FastPaymentContractAttributeList: Codable {
    let accountID, branchID, clientID: Int?
    let flagBankDefault, flagClientAgreementIn, flagClientAgreementOut, phoneNumber: String?
    let branchBIC: String?
    let fpcontractID: Int?
}

// MARK: FastPaymentContractAttributeList convenience initializers and mutators

extension FastPaymentContractAttributeList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FastPaymentContractAttributeList.self, from: data)
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
        branchID: Int?? = nil,
        clientID: Int?? = nil,
        flagBankDefault: String?? = nil,
        flagClientAgreementIn: String?? = nil,
        flagClientAgreementOut: String?? = nil,
        phoneNumber: String?? = nil,
        branchBIC: String?? = nil,
        fpcontractID: Int?? = nil
    ) -> FastPaymentContractAttributeList {
        return FastPaymentContractAttributeList(
            accountID: accountID ?? self.accountID,
            branchID: branchID ?? self.branchID,
            clientID: clientID ?? self.clientID,
            flagBankDefault: flagBankDefault ?? self.flagBankDefault,
            flagClientAgreementIn: flagClientAgreementIn ?? self.flagClientAgreementIn,
            flagClientAgreementOut: flagClientAgreementOut ?? self.flagClientAgreementOut,
            phoneNumber: phoneNumber ?? self.phoneNumber,
            branchBIC: branchBIC ?? self.branchBIC,
            fpcontractID: fpcontractID ?? self.fpcontractID
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - FastPaymentContractClAttributeList
struct FastPaymentContractClAttributeList: Codable {
    let clientInfo: ClientInfo?
}

// MARK: FastPaymentContractClAttributeList convenience initializers and mutators

extension FastPaymentContractClAttributeList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FastPaymentContractClAttributeList.self, from: data)
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
        clientInfo: ClientInfo?? = nil
    ) -> FastPaymentContractClAttributeList {
        return FastPaymentContractClAttributeList(
            clientInfo: clientInfo ?? self.clientInfo
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
// MARK: - ClientInfo
struct ClientInfo: Codable {
    let clientID: Int?
    let inn, name, nm, clientSurName: String?
    let clientPatronymicName, clientName, docType, regSeries: String?
    let regNumber, address: String?
}

// MARK: ClientInfo convenience initializers and mutators

extension ClientInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ClientInfo.self, from: data)
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
        clientID: Int?? = nil,
        inn: String?? = nil,
        name: String?? = nil,
        nm: String?? = nil,
        clientSurName: String?? = nil,
        clientPatronymicName: String?? = nil,
        clientName: String?? = nil,
        docType: String?? = nil,
        regSeries: String?? = nil,
        regNumber: String?? = nil,
        address: String?? = nil
    ) -> ClientInfo {
        return ClientInfo(
            clientID: clientID ?? self.clientID,
            inn: inn ?? self.inn,
            name: name ?? self.name,
            nm: nm ?? self.nm,
            clientSurName: clientSurName ?? self.clientSurName,
            clientPatronymicName: clientPatronymicName ?? self.clientPatronymicName,
            clientName: clientName ?? self.clientName,
            docType: docType ?? self.docType,
            regSeries: regSeries ?? self.regSeries,
            regNumber: regNumber ?? self.regNumber,
            address: address ?? self.address
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
