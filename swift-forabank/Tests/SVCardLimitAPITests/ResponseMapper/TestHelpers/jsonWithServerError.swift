//
//  jsonWithServerError.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2024.
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
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
