//
//  PaymentsTransfersPersonalViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

public struct PaymentsTransfersPersonalViewFactory<CategoryPickerView, OperationPickerView, Toolbar, TransfersView> {
    
    public let makeCategoryPickerView: MakeCategoryPickerView
    public let makeOperationPickerView: MakeOperationPickerView
    public let makeToolbar: MakeToolbar
    public let makeTransfersView: MakeTransfersView
    
    public init(
        @ViewBuilder makeCategoryPickerView: @escaping MakeCategoryPickerView,
        @ViewBuilder makeOperationPickerView: @escaping MakeOperationPickerView,
        @ToolbarContentBuilder makeToolbar: @escaping MakeToolbar,
        @ViewBuilder makeTransfersView: @escaping MakeTransfersView
    ) {
        self.makeCategoryPickerView = makeCategoryPickerView
        self.makeOperationPickerView = makeOperationPickerView
        self.makeToolbar = makeToolbar
        self.makeTransfersView = makeTransfersView
    }
}

public extension PaymentsTransfersPersonalViewFactory {
    
    typealias MakeCategoryPickerView = (CategoryPicker) -> CategoryPickerView
    typealias MakeOperationPickerView = (OperationPicker) -> OperationPickerView
    typealias MakeToolbar = () -> Toolbar
    typealias MakeTransfersView = (TransfersPicker) -> TransfersView
}
