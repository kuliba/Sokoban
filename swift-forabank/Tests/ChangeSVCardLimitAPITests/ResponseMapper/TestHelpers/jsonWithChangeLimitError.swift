//
//  jsonWithChangeLimitError.swift
//
//
//  Created by Andryusina Nataly on 14.06.2024.
//

import Foundation

func jsonWithChangeLimitError(
    jsonString: String = jsonWithChangeLimitError
) -> Data {
    
    .init(jsonString.utf8)
}

private let jsonWithChangeLimitError = """
{
    "statusCode": 102,
    "errorMessage": "Ошибка изменения лимита. Попробуйте позже (96)",
    "data": null
}
"""
