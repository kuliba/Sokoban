//
//  PaymentsTransfersPersonalViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

public struct PaymentsTransfersPersonalViewFactory<CategoryPickerView, OperationPickerView, Toolbar, ToolbarView, TransfersView> {
    
    public let makeCategoryPickerView: MakeCategoryPickerView
    public let makeOperationPickerView: MakeOperationPickerView
    public let makeToolbarView: MakeToolbarView
    public let makeTransfersView: MakeTransfersView
    
    public init(
        @ViewBuilder makeCategoryPickerView: @escaping MakeCategoryPickerView,
        @ViewBuilder makeOperationPickerView: @escaping MakeOperationPickerView,
        @ViewBuilder makeToolbarView: @escaping MakeToolbarView,
        @ViewBuilder makeTransfersView: @escaping MakeTransfersView
    ) {
        self.makeCategoryPickerView = makeCategoryPickerView
        self.makeOperationPickerView = makeOperationPickerView
        self.makeToolbarView = makeToolbarView
        self.makeTransfersView = makeTransfersView
    }
}

public extension PaymentsTransfersPersonalViewFactory {
    
    typealias MakeCategoryPickerView = (CategoryPicker) -> CategoryPickerView
    typealias MakeOperationPickerView = (OperationPicker) -> OperationPickerView
    typealias MakeToolbarView = (Toolbar) -> ToolbarView
    typealias MakeTransfersView = (TransfersPicker) -> TransfersView
}
