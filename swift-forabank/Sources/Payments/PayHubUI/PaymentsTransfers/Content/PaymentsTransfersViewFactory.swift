//
//  PaymentsTransfersViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

public struct PaymentsTransfersViewFactory<CategoryPicker, CategoryPickerView, OperationPicker, OperationPickerView, Toolbar, ToolbarView> {
    
    public let makeCategoryPickerView: MakeCategoryPickerView
    public let makeOperationPickerView: MakeOperationPickerView
    public let makeToolbarView: MakeToolbarView
    
    public init(
        @ViewBuilder makeCategoryPickerView: @escaping MakeCategoryPickerView,
        @ViewBuilder makeOperationPickerView: @escaping MakeOperationPickerView,
        @ViewBuilder makeToolbarView: @escaping MakeToolbarView
    ) {
        self.makeCategoryPickerView = makeCategoryPickerView
        self.makeOperationPickerView = makeOperationPickerView
        self.makeToolbarView = makeToolbarView
    }
}

public extension PaymentsTransfersViewFactory {
    
    typealias MakeCategoryPickerView = (CategoryPicker) -> CategoryPickerView
    typealias MakeOperationPickerView = (OperationPicker) -> OperationPickerView
    typealias MakeToolbarView = (Toolbar) -> ToolbarView
}
