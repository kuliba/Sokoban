//
//  TestHelpers.swift
//  
//
//  Created by Andryusina Nataly on 22.01.2024.
//

import CardStatementAPI

typealias Result = Swift.Result<ProductStatementWithExtendedInfo, MappingError>

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

func dynamicParamsError(
    _ message: String
) -> ResponseMapper.GetProductDynamicParamsListResult {
    
    .failure(.mappingFailure(message))
}

func dynamicParamsErrorNot200(
    _ message: String
) -> ResponseMapper.GetProductDynamicParamsListResult {
    
    .failure(.not200Status(message))
}

func dynamicParamsDefaultError(
) -> ResponseMapper.GetProductDynamicParamsListResult {
    
    dynamicParamsError(.defaultErrorMessage)
}
