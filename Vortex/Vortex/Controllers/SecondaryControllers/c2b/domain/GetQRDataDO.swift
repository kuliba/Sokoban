//
//  GetQRData.swift
//  ForaBank
//
//  Created by Роман Воробьев on 16.03.2022.
//

import Foundation

struct GetQRDataRequest: NetworkModelProtocol, Codable {

    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetQRDataRequest.self, from: data)
    }

    let statusCode: Int?
    let errorMessage: String?
    let data: [Datum3]?
}

// MARK: - Datum
struct Datum3 : Codable {
    let QRLink: String?
}

struct GetQRDataAnswer: NetworkModelProtocol, Codable {

    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetQRDataAnswer.self, from: data)
    }

    init(statusCode: Int?, errorMessage: String?, data: Datum4?) {
        self.statusCode = statusCode
        self.errorMessage = errorMessage
        self.data = data
    }

    let statusCode: Int?
    let errorMessage: String?
    let data: Datum4?
}

struct Datum4 : Codable {
    let parameters: [Parameter2]?
}

// MARK: - Parameter
struct Parameter2 : Codable {
    let type, id, value, title: String?
    let name, description, icon, currency: String?
}

