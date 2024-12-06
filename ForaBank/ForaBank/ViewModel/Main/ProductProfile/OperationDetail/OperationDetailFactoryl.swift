//
//  OperationDetailFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 29.01.2024.
//

import Foundation

struct OperationDetailFactory {
    
    let makeOperationDetailViewModel: MakeOperationDetailViewModel
      
    typealias MakeOperationDetailViewModel = (ProductStatementData, ProductData, Model) -> OperationDetailViewModel
}
