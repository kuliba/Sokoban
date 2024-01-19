//
//  jsonWithServerError.swift
//  
//
//  Created by Igor Malyarov on 28.12.2023.
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
