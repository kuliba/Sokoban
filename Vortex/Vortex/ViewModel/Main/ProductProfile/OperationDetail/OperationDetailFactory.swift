//
//  OperationDetailFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 29.01.2024.
//

import SwiftUI

struct OperationDetailFactory {
    
    let makeOperationDetailViewModel: MakeOperationDetailViewModel
    
    enum OperationDetail {
        
        case legacy(OperationDetailViewModel)
        case v3(StatementDetails)
    }
    
    typealias MakeOperationDetailViewModel = (ProductData.ID, ProductStatementData.ID) -> OperationDetail?
}

// TODO: move top OperationDetailsDomain(?)
struct StatementDetails {
    
    let content: Content
    let model: OperationDetailDomain.Model
    
    struct Content: Equatable {
        
        let logo: String? // Лого- md5hash из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
        let name: String? // Наименование получателя-    foreignName из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
    }
}
