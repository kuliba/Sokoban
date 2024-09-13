//
//  jsonWithServerError.swift
//  
//
//  Created by Andryusina Nataly on 12.02.2024.
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
