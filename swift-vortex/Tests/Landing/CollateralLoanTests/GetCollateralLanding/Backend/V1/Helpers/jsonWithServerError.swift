//
//  jsonWithServerError.swift
//
//
//  Created by Valentin Ozerov on 02.12.2024.
//

import Foundation

func jsonWithServerError(
    jsonString: String = jsonStringWithServerError
) -> Data {
    
    .init(jsonString.utf8)
}

private let jsonStringWithServerError = """
{
    "statusCode": 102,
    "errorMessage": "Серверная ошибка при выполнении запроса",
    "data": null
}
"""
