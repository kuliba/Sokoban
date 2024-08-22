//
//  PaymentsTransfersViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

public struct PaymentsTransfersViewFactory<CategoryPicker, CategoryPickerView, PayHub, PayHubView> {
    
    public let makeCategoryPickerView: MakeCategoryPickerView
    public let makePayHubView: MakePayHubView
    
    public init(
        makeCategoryPickerView: @escaping MakeCategoryPickerView,
        makePayHubView: @escaping MakePayHubView
    ) {
        self.makeCategoryPickerView = makeCategoryPickerView
        self.makePayHubView = makePayHubView
    }
}

public extension PaymentsTransfersViewFactory {
    
    typealias MakeCategoryPickerView = (CategoryPicker) -> CategoryPickerView
    typealias MakePayHubView = (PayHub) -> PayHubView
}
