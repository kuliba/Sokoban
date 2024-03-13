//
//  GetProductListByTypeResultError.swift
//  ForaBank
//
//  Created by Disman Dmitry on 13.03.2024.
//

import Foundation

enum GetProductListByTypeResultError: Error {

    case invalidData(statusCode: Int, data: Data)
    case error(statusCode: Int, errorMessage: String)
}
