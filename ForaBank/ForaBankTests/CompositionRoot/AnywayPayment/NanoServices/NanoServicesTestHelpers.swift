//
//  NanoServicesTestHelpers.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 27.03.2024.
//

import Foundation

extension Data {
    
    static let empty: Self = .init()
    static let emptyJSON: Self = json("{}")
    static let emptyArrayJSON: Self = json("[]")
    static let invalid: Self = json("invalid data")
    static let nullServerResponse: Self = json(.nullServerResponse)
    static let emptyServerData: Self = json(.emptyServerData)
    static let emptyArrayServerData: Self = json(.emptyArrayServerData)
    static let invalidServerData: Self = json(.invalidServerData)
    static let serverError: Self = json(.serverError)
    
    static func json(_ string: String) -> Data {
        
        .init(string.utf8)
    }
}

private extension String {
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let emptyServerData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let emptyArrayServerData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": []
}
"""
    
    static let invalidServerData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
}
