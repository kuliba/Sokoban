//
//  jsonWithGetLimitError.swift
//
//
//  Created by Andryusina Nataly on 18.06.2024.
//

import Foundation

func jsonWithGetLimitError(
    jsonString: String = jsonWithChangeLimitError
) -> Data {
    
    .init(jsonString.utf8)
}

private let jsonWithChangeLimitError = """
{
    "statusCode": 102,
    "errorMessage": "Ошибка получения лимитов. Попробуйте позже (1006)",
    "data": null
}
"""
