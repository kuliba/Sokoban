//
//  OperationDetailFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 29.01.2024.
//

struct OperationDetailFactory {
    
    let makeOperationDetailViewModel: MakeOperationDetailViewModel
    
    typealias MakeOperationDetailViewModel = (ProductData.ID, ProductStatementData.ID) -> OperationDetail?
    
    enum OperationDetail {
        
        case legacy(OperationDetailViewModel)
        case v3(StatementDetailsDomain.Model)
    }
}
