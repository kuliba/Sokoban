//
//  GetNotificationsDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import Foundation

// MARK: - GetNotificationsDecodableModel
struct GetNotificationsDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetNotifications]?
}

// MARK: GetNotificationsDecodableModel convenience initializers and mutators
extension GetNotificationsDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetNotificationsDecodableModel.self, from: data)
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
        data: [GetNotifications]?? = nil
    ) -> GetNotificationsDecodableModel {
        return GetNotificationsDecodableModel(
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


// MARK: - GetNotifications
struct GetNotifications: Codable {
    let date: String?
    let title: String?
    let text, type, state: String?
}

// MARK: Datum convenience initializers and mutators

extension GetNotifications {
    
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetNotifications.self, from: data)
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
        date: String?? = nil,
        title: String?? = nil,
        text: String?? = nil,
        type: String?? = nil,
        state: String?? = nil
    ) -> GetNotifications {
        return GetNotifications(
            date: date ?? self.date,
            title: title ?? self.title,
            text: text ?? self.text,
            type: type ?? self.type,
            state: state ?? self.state
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

