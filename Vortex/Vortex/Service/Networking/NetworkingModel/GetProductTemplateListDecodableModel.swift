//
//  GetProductTemplateListDecodableModel.swift
//  Vortex
//
//  Created by Константин Савялов on 08.07.2021.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getProductTemplateListDecodableModel = try GetProductTemplateListDecodableModel(json)

import Foundation

// MARK: - GetProductTemplateListDecodableModel
struct GetProductTemplateListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetProductTemplateDatum]?
}

// MARK: GetProductTemplateListDecodableModel convenience initializers and mutators

extension GetProductTemplateListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetProductTemplateListDecodableModel.self, from: data)
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
        data: [GetProductTemplateDatum]?? = nil
    ) -> GetProductTemplateListDecodableModel {
        return GetProductTemplateListDecodableModel(
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

// MARK: - GetProductTemplateDatum
struct GetProductTemplateDatum: Codable {
    
    internal init(id: Int?, numberMask: String?, customName: String?, currency: String?, type: String?, smallDesign: SVGImageData?, paymentSystemImage: SVGImageData?) {
        self.id = id
        self.numberMask = numberMask
        self.customName = customName
        self.currency = currency
        self.type = type
        self.smallDesign = smallDesign
        self.paymentSystemImage = paymentSystemImage
    }
    
    init(with productTemplateData: ProductTemplateData) {
        self.id = productTemplateData.id
        self.numberMask = productTemplateData.numberMask
        self.customName = productTemplateData.customName
        self.currency = productTemplateData.currency
        self.type = productTemplateData.type.rawValue
        self.smallDesign = nil //productTemplateData.smallDesign
        self.paymentSystemImage = nil //productTemplateData.paymentSystemImage
    }
    
    let id: Int?
    let numberMask, customName, currency, type: String?
    let smallDesign, paymentSystemImage: SVGImageData?
}

extension GetProductTemplateDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetProductTemplateDatum.self, from: data)
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
        id: Int?? = nil,
        numberMask: String?? = nil,
        customName: String?? = nil,
        currency: String?? = nil,
        type: String?? = nil,
        smallDesign: SVGImageData?? = nil,
        paymentSystemImage: SVGImageData?? = nil
    ) -> GetProductTemplateDatum {
        return GetProductTemplateDatum(
            id: id ?? self.id,
            numberMask: numberMask ?? self.numberMask,
            customName: customName ?? self.customName,
            currency: currency ?? self.currency,
            type: type ?? self.type,
            smallDesign: smallDesign ?? self.smallDesign,
            paymentSystemImage: paymentSystemImage ?? self.paymentSystemImage
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
