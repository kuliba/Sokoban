//
//  PaymentsTransfersPersonalNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import PayHubUI

struct PaymentsTransfersPersonalNanoServices {
    
    let loadCategories: LoadCategories
    let reloadCategories: LoadCategories
    let loadAllLatest: LoadAllLatest
}

extension PaymentsTransfersPersonalNanoServices {
    
    typealias LoadCategoriesCompletion = ([ServiceCategory]?) -> Void
    typealias LoadCategories = (@escaping LoadCategoriesCompletion) -> Void
    
    typealias LoadLatestCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadAllLatest = (@escaping LoadLatestCompletion) -> Void
}
