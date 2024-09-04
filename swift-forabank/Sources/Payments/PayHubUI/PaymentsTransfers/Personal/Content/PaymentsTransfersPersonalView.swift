//
//  PaymentsTransfersPersonalView.swift
//
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersPersonalView<CategoryPicker, CategoryPickerView, OperationPicker, OperationPickerView, Toolbar, ToolbarView>: View
where CategoryPickerView: View,
      OperationPickerView: View,
      ToolbarView: View {
    
    @ObservedObject private var model: Content
    
    private let factory: Factory
    private let config: Config
    
    public init(
        model: Content,
        factory: Factory,
        config: Config
    ) {
        self.model = model
        self.factory = factory
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            Button("Reload | to be replaced with \"swipe to refresh\")".uppercased(), action: model.reload)
                .foregroundColor(.blue)
                .font(.caption.bold())
            
            VStack(alignment: .leading, spacing: config.titleSpacing) {
                
                config.title.render()
                
                factory.makeOperationPickerView(model.operationPicker)
            }
            
            transfersView()
            
            factory.makeCategoryPickerView(model.categoryPicker)
        }
        .padding(.top)
        .padding(.horizontal)
        .background(factory.makeToolbarView(model.toolbar))
    }
}

public extension PaymentsTransfersPersonalView {
    
    typealias Content = PaymentsTransfersPersonalContent<CategoryPicker, OperationPicker, Toolbar>
    typealias Factory = PaymentsTransfersPersonalViewFactory<CategoryPicker, CategoryPickerView, OperationPicker, OperationPickerView, Toolbar, ToolbarView>
    typealias Config = PaymentsTransfersPersonalViewConfig
}

private extension PaymentsTransfersPersonalView {
    
    func transfersView() -> some View {
        
        VStack(spacing: 32) {
            
            ZStack {
                
                Color.black.opacity(0.75)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text("TBD: Transfers")
                    .foregroundColor(.white)
                    .font(.headline.bold())
            }
            .frame(height: 124)
        }
    }
}

// MARK: - Previews

#Preview {
    PaymentsTransfersPersonalView(
        model: .preview,
        factory: .init(
            makeCategoryPickerView: { (categoryPicker: PreviewCategoryPicker) in
                
                Text("Category Picker")
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
        ),
        config: .preview
    )
}

private extension PaymentsTransfersPersonalContent
where CategoryPicker == PreviewCategoryPicker,
      OperationPicker == PreviewPayHub,
      Toolbar == PreviewToolbar {
    
    static var preview: PaymentsTransfersPersonalContent {
        
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
