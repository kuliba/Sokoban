//
//  PaymentsTransfersPersonalNanoServices.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.09.2024.
//

import PayHub
import PayHubUI

struct PaymentsTransfersPersonalNanoServices {
    
    let loadCategories: LoadCategories
    let reloadCategories: ReloadCategories
    let loadAllLatest: LoadAllLatest
}

extension PaymentsTransfersPersonalNanoServices {
    
    typealias LoadCategoriesCompletion = ([ServiceCategory]?) -> Void
    typealias LoadCategories = (@escaping LoadCategoriesCompletion) -> Void
    
    typealias Notify = (ItemListEvent<ServiceCategory>) -> Void
    typealias ReloadCategories = (@escaping Notify, @escaping LoadCategoriesCompletion) -> Void
    
    typealias LoadLatestCompletion = ([Latest]?) -> Void
    typealias LoadAllLatest = (@escaping LoadLatestCompletion) -> Void
}
