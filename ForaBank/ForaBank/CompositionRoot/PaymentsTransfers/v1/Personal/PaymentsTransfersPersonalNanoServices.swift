//
//  PaymentsTransfersPersonalNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import PayHubUI

struct PaymentsTransfersPersonalNanoServices {
    
    let loadCategories: LoadCategories
    let loadAllLatest: LoadAllLatest
    let loadLatestForCategory: LoadLatestForCategory
    let loadOperators: LoadOperators
}

extension PaymentsTransfersPersonalNanoServices {
    
    typealias LoadCategoriesCompletion = ([CategoryPickerSectionItem<ServiceCategory>]) -> Void
    typealias LoadCategories = (@escaping LoadCategoriesCompletion) -> Void
    
    typealias LoadAllLatestCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadAllLatest = (@escaping LoadAllLatestCompletion) -> Void
    
    typealias LoadLatestForCategoryCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadLatestForCategory = (ServiceCategory, @escaping LoadLatestForCategoryCompletion) -> Void
    
    typealias LoadOperatorsCompletion = (Result<[Operator], Error>) -> Void
    typealias LoadOperators = (ServiceCategory, @escaping LoadOperatorsCompletion) -> Void
}
