//
//  VerifyCodeDecodebleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let verifyCodeDecodebleModel = try VerifyCodeDecodebleModel(json)

import Foundation

// MARK: - VerifyCodeDecodebleModel
struct VerifyCodeDecodebleModel: Codable, NetworkModelProtocol {
    let appID, verificationCode: String?

    enum CodingKeys: String, CodingKey {
        case appID 
        case verificationCode
    }
}

// MARK: VerifyCodeDecodebleModel convenience initializers and mutators

extension VerifyCodeDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(VerifyCodeDecodebleModel.self, from: data)
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
        appID: String?? = nil,
        verificationCode: String?? = nil
    ) -> VerifyCodeDecodebleModel {
        return VerifyCodeDecodebleModel(
            appID: appID ?? self.appID,
            verificationCode: verificationCode ?? self.verificationCode
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
