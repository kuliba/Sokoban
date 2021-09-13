//
//  GetMe2MeDebitConsentDecodableModel.swift
//  ForaBank
//
//  Created by Mikhail on 13.09.2021.
//

import Foundation

// MARK: - GetMe2MeDebitConsentDecodableModel
struct GetMe2MeDebitConsentDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetMe2MeDebitConsentDataClass?
}

// MARK: GetMe2MeDebitConsentDecodableModel convenience initializers and mutators

extension GetMe2MeDebitConsentDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetMe2MeDebitConsentDecodableModel.self, from: data)
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
        data: GetMe2MeDebitConsentDataClass?? = nil
    ) -> GetMe2MeDebitConsentDecodableModel {
        return GetMe2MeDebitConsentDecodableModel(
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

// MARK: - GetMe2MeDebitConsentDataClass
struct GetMe2MeDebitConsentDataClass: Codable {

    let cardId, accountId: Int?
    let amount: Double?
    let fee: Double?
    let bankRecipientID, recipientID, rcvrMsgId, refTrnId: String?
    
}

// MARK: GetMe2MeDebitConsentDataClass convenience initializers and mutators

extension GetMe2MeDebitConsentDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetMe2MeDebitConsentDataClass.self, from: data)
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
        cardId: Int?? = nil,
        accountId: Int?? = nil,
        amount: Double?? = nil,
        fee: Double?? = nil,
        bankRecipientID: String?? = nil,
        recipientID: String?? = nil,
        rcvrMsgId: String?? = nil,
        refTrnId: String?? = nil
    ) -> GetMe2MeDebitConsentDataClass {
        return GetMe2MeDebitConsentDataClass(
            cardId: cardId ?? self.cardId,
            accountId: accountId ?? self.accountId,
            amount: amount ?? self.amount,
            fee: fee ?? self.fee,
            bankRecipientID: bankRecipientID ?? self.bankRecipientID,
            recipientID: recipientID ?? self.recipientID,
            rcvrMsgId: rcvrMsgId ?? self.rcvrMsgId,
            refTrnId: refTrnId ?? self.refTrnId
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
