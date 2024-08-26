//
//  PaymentsTransfersView.swift
//
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersView<CategoryPicker, CategoryPickerView, OperationPicker, OperationPickerView, Toolbar, ToolbarView>: View
where CategoryPickerView: View,
      OperationPickerView: View,
      ToolbarView: View {
    
    @ObservedObject private var model: Model
    
    private let factory: Factory
    
    public init(
        model: Model,
        factory: Factory
    ) {
        self.model = model
        self.factory = factory
    }
    
    public var body: some View {
        
        VStack(spacing: 32) {
            
            Button("Reload | to be replaced with \"swipe to refresh\")", action: model.reload)
            
            factory.makeOperationPickerView(model.operationPicker)
            
            factory.makeCategoryPickerView(model.categoryPicker)
            
            Spacer()
        }
        .padding()
        .background(factory.makeToolbarView(model.toolbar))
    }
}

public extension PaymentsTransfersView {
    
    typealias Model = PaymentsTransfersModel<CategoryPicker, OperationPicker, Toolbar>
    typealias Factory = PaymentsTransfersViewFactory<CategoryPicker, CategoryPickerView, OperationPicker, OperationPickerView, Toolbar, ToolbarView>
}

// MARK: - Previews

#Preview {
    PaymentsTransfersView(
        model: .preview,
        factory: .init(
            makeCategoryPickerView: { (categoryPicker: PreviewCategoryPicker) in
                
                Text("Category Pickeer")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
            },
            makeOperationPickerView: { (payHub: PreviewPayHub) in
                
                Text("Operation Picker")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
            },
            makeToolbarView: {
                
                Text("Toolbar \(String(describing: $0))")
            }
        )
    )
}

private extension PaymentsTransfersModel
where CategoryPicker == PreviewCategoryPicker,
      OperationPicker == PreviewPayHub,
      Toolbar == PreviewToolbar {
    
    static var preview: PaymentsTransfersModel {
        
        return .init(
            categoryPicker: .init(),
            operationPicker: .init(),
            toolbar: .init(),
            reload: {}
        )
    }
}

private final class PreviewCategoryPicker {}

private final class PreviewPayHub {}

private final class PreviewToolbar {}
