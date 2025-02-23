//
//  OperationDetailFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 29.01.2024.
//

import Foundation

struct OperationDetailFactory {
    
    let makeOperationDetailViewModel: MakeOperationDetailViewModel
    
    enum OperationDetail {
        
        case legacy(OperationDetailViewModel)
        case v3(StatementDetails)
    }
    
    typealias MakeOperationDetailViewModel = (ProductData.ID, ProductStatementData.ID) -> OperationDetail?
}

struct StatementDetails {
    
    let model: OperationDetailDomain.Model
}
