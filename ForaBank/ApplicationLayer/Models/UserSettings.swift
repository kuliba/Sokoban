import Foundation
import Alamofire

// MARK: - UserSettings
struct UserSettings: Codable {
    var settingName, settingSysName, settingValue: String?
}

// MARK: UserSettings convenience initializers and mutators

extension UserSettings {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserSettings.self, from: data)
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
        settingName: String?? = nil,
        settingSysName: String?? = nil,
        settingValue: String?? = nil
    ) -> UserSettings {
        return UserSettings(
            settingName: settingName ?? self.settingName,
            settingSysName: settingSysName ?? self.settingSysName,
            settingValue: settingValue ?? self.settingValue
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// JSONSchemaSupport.swift

import Foundation

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func userSettingsTask(with url: URL, completionHandler: @escaping (UserSettings?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}

// MARK: - Alamofire response handlers

