//
//  PaymentsTransfersView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersView<CategoryPicker, CategoryPickerView, OperationPicker, OperationPickerView, Toolbar, ToolbarView>: View
where CategoryPicker: Loadable,
      CategoryPickerView: View,
      OperationPicker: Loadable,
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
            
            factory.makeToolbarView(model.toolbar)
            
            factory.makeOperationPickerView(model.operationPicker)
            
            factory.makeCategoryPickerView(model.categoryPicker)
            
            Spacer()
        }
        .padding()
    }
}

public extension PaymentsTransfersView {
    
    typealias Model = PaymentsTransfersModel<CategoryPicker, OperationPicker, Toolbar>
    typealias Factory = PaymentsTransfersViewFactory<CategoryPicker, CategoryPickerView, OperationPicker, OperationPickerView, Toolbar, ToolbarView>
}

extension PaymentsTransfersModel
where CategoryPicker: Loadable,
      OperationPicker: Loadable {
    
    func reload() {
        
        categoryPicker.load()
        operationPicker.load()
    }
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
            toolbar: .init()
        )
    }
}

private final class PreviewCategoryPicker: Loadable {
    
    func load() {}
}

private final class PreviewPayHub: Loadable {
    
    func load() {}
}

private final class PreviewToolbar {}
