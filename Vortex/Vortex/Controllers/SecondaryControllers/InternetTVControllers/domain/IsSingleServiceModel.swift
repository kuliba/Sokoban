//
//  IsSingleServiceModel.swift
//  ForaBank
//
//  Created by Роман Воробьев on 04.12.2021.
//

import Foundation

struct IsSingleServiceModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: Bool?

    init(data: Data) throws {
        self = try newJSONDecoder().decode(IsSingleServiceModel.self, from: data)
    }
}