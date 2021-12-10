//
//  MakeDepositDecodableModel.swift
//  ForaBank
//
//  Created by Mikhail on 08.12.2021.
//

import Foundation

// MARK: - MakeDepositDecodableModel
struct MakeDepositDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: MakeDepositDataDecodableModel?
}

// MARK: MakeDepositDecodableModel convenience initializers and mutators

extension MakeDepositDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MakeDepositDecodableModel.self, from: data)
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
        data: MakeDepositDataDecodableModel?? = nil
    ) -> MakeDepositDecodableModel {
        return MakeDepositDecodableModel(
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

// MARK: - MakeDepositDataDecodableModel
struct MakeDepositDataDecodableModel: Codable {
    let documentStatus: String?
    let accountNumber: String?
    let closeDate: Int?
    let paymentOperationDetailId: Int?
}

// MARK: MakeDepositDataDecodableModel convenience initializers and mutators

extension MakeDepositDataDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MakeDepositDataDecodableModel.self, from: data)
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
        documentStatus: String?? = nil,
        accountNumber: String?? = nil,
        closeDate: Int?? = nil,
        paymentOperationDetailId: Int?? = nil
    ) -> MakeDepositDataDecodableModel {
        return MakeDepositDataDecodableModel(
            documentStatus: documentStatus ?? self.documentStatus,
            accountNumber: accountNumber ?? self.accountNumber,
            closeDate: closeDate ?? self.closeDate,
            paymentOperationDetailId: paymentOperationDetailId ?? self.paymentOperationDetailId
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
