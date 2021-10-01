//
//  GetPhoneInfoDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.09.2021.
//

import Foundation

// MARK: - GetPhoneInfoDecodableModel
struct GetPhoneInfoDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetPhoneInfoDatum]?
}

// MARK: GetPhoneInfoDecodableModel convenience initializers and mutators

extension GetPhoneInfoDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetPhoneInfoDecodableModel.self, from: data)
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
        data: [GetPhoneInfoDatum]?? = nil
    ) -> GetPhoneInfoDecodableModel {
        return GetPhoneInfoDecodableModel(
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

// MARK: - GetPhoneInfoDatum
struct GetPhoneInfoDatum: Codable {
    let source, type, phone, countryCode: String?
    let cityCode, number: String?
    let datumExtension: JSONNull?
    let provider, puref, md5Hash, svgImage: String?
    let country, region, city, timezone: String?
    let qcConflict, qc: Int?

    enum CodingKeys: String, CodingKey {
        case source, type, phone, countryCode, cityCode, number
        case datumExtension = "extension"
        case provider, puref
        case md5Hash = "md5hash"
        case svgImage, country, region, city, timezone, qcConflict, qc
    }
}

// MARK: Datum convenience initializers and mutators

extension GetPhoneInfoDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetPhoneInfoDatum.self, from: data)
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
        source: String?? = nil,
        type: String?? = nil,
        phone: String?? = nil,
        countryCode: String?? = nil,
        cityCode: String?? = nil,
        number: String?? = nil,
        datumExtension: JSONNull?? = nil,
        provider: String?? = nil,
        puref: String?? = nil,
        md5Hash: String?? = nil,
        svgImage: String?? = nil,
        country: String?? = nil,
        region: String?? = nil,
        city: String?? = nil,
        timezone: String?? = nil,
        qcConflict: Int?? = nil,
        qc: Int?? = nil
    ) -> GetPhoneInfoDatum {
        return GetPhoneInfoDatum (
            source: source ?? self.source,
            type: type ?? self.type,
            phone: phone ?? self.phone,
            countryCode: countryCode ?? self.countryCode,
            cityCode: cityCode ?? self.cityCode,
            number: number ?? self.number,
            datumExtension: datumExtension ?? self.datumExtension,
            provider: provider ?? self.provider,
            puref: puref ?? self.puref,
            md5Hash: md5Hash ?? self.md5Hash,
            svgImage: svgImage ?? self.svgImage,
            country: country ?? self.country,
            region: region ?? self.region,
            city: city ?? self.city,
            timezone: timezone ?? self.timezone,
            qcConflict: qcConflict ?? self.qcConflict,
            qc: qc ?? self.qc
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
