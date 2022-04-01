//
//  GetOperationDetailByPaymentIdDO.swift
//  ForaBank
//
//  Created by Роман Воробьев on 31.03.2022.
//

import Foundation

struct GetOperationDetailsByPaymentIdAnswer: NetworkModelProtocol, Codable {

    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetOperationDetailsByPaymentIdAnswer.self, from: data)
    }

    let statusCode: Int?
    let errorMessage: String?
    let data: GetOperationDetailsByPaymentIdDatum?
}

struct GetOperationDetailsByPaymentIdDatum: Codable {
    let amount: Double?
    let dateForDetail: String?
    let merchantSubName: String?
    let operationStatus: String?
    let payeeFullName: String?
    let payeeBankName: String?
    let comment: String?
    let transferNumber: String?
}
