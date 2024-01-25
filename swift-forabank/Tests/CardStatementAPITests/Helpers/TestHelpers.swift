//
//  TestHelpers.swift
//  
//
//  Created by Andryusina Nataly on 22.01.2024.
//

import CardStatementAPI

typealias Result = Swift.Result<[ProductStatementData], MappingError>

func сardStatementError(
    _ message: String
) -> Result {
    
    .failure(.mappingFailure(message))
}

func сardStatementErrorNot200(
    _ message: String
) -> Result {
    
    .failure(.not200Status(message))
}

func сardStatementDefaultError(
) -> Result {
    
    сardStatementError(.defaultErrorMessage)
}
