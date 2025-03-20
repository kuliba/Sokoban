//
//  OperationDetailFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 29.01.2024.
//

import SwiftUI

struct OperationDetailFactory {
    
    let makeOperationDetailViewModel: MakeOperationDetailViewModel
    
    typealias MakeOperationDetailViewModel = (ProductData.ID, ProductStatementData.ID) -> OperationDetail?
    
    enum OperationDetail {
        
        case legacy(OperationDetailViewModel)
        case v3(StatementDetails)
    }
}

struct StatementDetails {
    
    let content: Content
    let details: OperationDetailDomain.Model
    let document: C2GDocumentButtonDomain.Binder?
    
    struct Content: Equatable {
        
        let logo: String? // Лого- md5hash из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
        let name: String? // Наименование получателя-    foreignName из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
    }
}
