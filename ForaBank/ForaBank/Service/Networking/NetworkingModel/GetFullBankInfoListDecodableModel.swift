//
//  GetFullBankInfoListDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 27.07.2021.
//

// GetFullBankInfoListDecodableModel.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getFullBankInfoListDecodableModel = try GetFullBankInfoListDecodableModel(json)

import Foundation

// MARK: - GetFullBankInfoListDecodableModel
struct GetFullBankInfoListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetFullBankInfoListDecodableModelDataClass?
}

// MARK: GetFullBankInfoListDecodableModel convenience initializers and mutators

extension GetFullBankInfoListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetFullBankInfoListDecodableModel.self, from: data)
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
        data: GetFullBankInfoListDecodableModelDataClass?? = nil
    ) -> GetFullBankInfoListDecodableModel {
        return GetFullBankInfoListDecodableModel(
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

// MARK: - GetFullBankInfoListDecodableModelDataClass
struct GetFullBankInfoListDecodableModelDataClass: Codable {
    let serial: String?
    let bankFullInfoList: [BankFullInfoList]?
}

// MARK: GetFullBankInfoListDecodableModelDataClass convenience initializers and mutators

extension GetFullBankInfoListDecodableModelDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetFullBankInfoListDecodableModelDataClass.self, from: data)
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
        serial: String?? = nil,
        bankFullInfoList: [BankFullInfoList]?? = nil
    ) -> GetFullBankInfoListDecodableModelDataClass {
        return GetFullBankInfoListDecodableModelDataClass(
            serial: serial ?? self.serial,
            bankFullInfoList: bankFullInfoList ?? self.bankFullInfoList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - BankFullInfoList
struct BankFullInfoList: Codable {
    let name, memberID, rusName, fullName, engName: String?
    let md5Hash, svgImage, bic, fiasID: String?
    let address, latitude, longitude: String?
    let swiftList: [JSONAny]?
    let inn, kpp, registrationNumber, registrationDate: String?
    let bankType, bankTypeCode, bankServiceType, bankServiceTypeCode: String?
    let accountList: [AccountList]?

    enum CodingKeys: String, CodingKey {
        case name
        case memberID = "memberId"
        case fullName, engName, rusName
        case md5Hash = "md5hash"
        case svgImage, bic
        case fiasID = "fiasId"
        case address, latitude, longitude, swiftList, inn, kpp, registrationNumber, registrationDate, bankType, bankTypeCode, bankServiceType, bankServiceTypeCode, accountList
    }
}

// MARK: BankFullInfoList convenience initializers and mutators

extension BankFullInfoList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BankFullInfoList.self, from: data)
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
        name: String?? = nil,
        memberID: String?? = nil,
        rusName: String?? = nil,
        fullName: String?? = nil,
        engName: String?? = nil,
        md5Hash: String?? = nil,
        svgImage: String?? = nil,
        bic: String?? = nil,
        fiasID: String?? = nil,
        address: String?? = nil,
        latitude: String?? = nil,
        longitude: String?? = nil,
        swiftList: [JSONAny]?? = nil,
        inn: String?? = nil,
        kpp: String?? = nil,
        registrationNumber: String?? = nil,
        registrationDate: String?? = nil,
        bankType: String?? = nil,
        bankTypeCode: String?? = nil,
        bankServiceType: String?? = nil,
        bankServiceTypeCode: String?? = nil,
        accountList: [AccountList]?? = nil
    ) -> BankFullInfoList {
        return BankFullInfoList(
            name: name ?? self.name,
            memberID: memberID ?? self.memberID,
            rusName: rusName ?? self.rusName,
            fullName: fullName ?? self.fullName,
            engName: engName ?? self.engName,
            md5Hash: md5Hash ?? self.md5Hash,
            svgImage: svgImage ?? self.svgImage,
            bic: bic ?? self.bic,
            fiasID: fiasID ?? self.fiasID,
            address: address ?? self.address,
            latitude: latitude ?? self.latitude,
            longitude: longitude ?? self.longitude,
            swiftList: swiftList ?? self.swiftList,
            inn: inn ?? self.inn,
            kpp: kpp ?? self.kpp,
            registrationNumber: registrationNumber ?? self.registrationNumber,
            registrationDate: registrationDate ?? self.registrationDate,
            bankType: bankType ?? self.bankType,
            bankTypeCode: bankTypeCode ?? self.bankTypeCode,
            bankServiceType: bankServiceType ?? self.bankServiceType,
            bankServiceTypeCode: bankServiceTypeCode ?? self.bankServiceTypeCode,
            accountList: accountList ?? self.accountList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - AccountList
struct AccountList: Codable {
    let account, regulationAccountType, ck, dateIn: String?
    let dateOut, status, cbrbic: String?

    enum CodingKeys: String, CodingKey {
        case account, regulationAccountType, ck, dateIn, dateOut, status
        case cbrbic = "CBRBIC"
    }
}

// MARK: AccountList convenience initializers and mutators

extension AccountList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AccountList.self, from: data)
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
        account: String?? = nil,
        regulationAccountType: String?? = nil,
        ck: String?? = nil,
        dateIn: String?? = nil,
        dateOut: String?? = nil,
        status: String?? = nil,
        cbrbic: String?? = nil
    ) -> AccountList {
        return AccountList(
            account: account ?? self.account,
            regulationAccountType: regulationAccountType ?? self.regulationAccountType,
            ck: ck ?? self.ck,
            dateIn: dateIn ?? self.dateIn,
            dateOut: dateOut ?? self.dateOut,
            status: status ?? self.status,
            cbrbic: cbrbic ?? self.cbrbic
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

