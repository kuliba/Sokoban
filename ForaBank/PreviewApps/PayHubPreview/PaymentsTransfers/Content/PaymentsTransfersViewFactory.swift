//
//  PaymentsTransfersViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct PaymentsTransfersViewFactory<CategoryPicker, CategoryPickerView, PayHub, PayHubView> {
    
    let makeCategoryPickerView: MakeCategoryPickerView
    let makePayHubView: MakePayHubView
}

extension PaymentsTransfersViewFactory {
    
    typealias MakeCategoryPickerView = (CategoryPicker) -> CategoryPickerView
    typealias MakePayHubView = (PayHub) -> PayHubView
}
