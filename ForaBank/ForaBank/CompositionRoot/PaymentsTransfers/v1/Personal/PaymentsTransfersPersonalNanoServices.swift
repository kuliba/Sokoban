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
}

extension PaymentsTransfersPersonalNanoServices {
    
    typealias LoadCategoriesCompletion = ([CategoryPickerSectionItem<ServiceCategory>]) -> Void
    typealias LoadCategories = (@escaping LoadCategoriesCompletion) -> Void
    
    typealias LoadLatestCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadAllLatest = (@escaping LoadLatestCompletion) -> Void
    typealias LoadLatestForCategory = (ServiceCategory, @escaping LoadLatestCompletion) -> Void
}
