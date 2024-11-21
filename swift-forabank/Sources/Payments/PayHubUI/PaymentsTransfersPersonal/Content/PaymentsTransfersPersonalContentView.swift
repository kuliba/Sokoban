//
//  PaymentsTransfersPersonalContentView.swift
//
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersPersonalContentView<CategoryPickerView, OperationPickerView, Toolbar, ToolbarView, Transfers, TransfersView>: View
where CategoryPickerView: View,
      OperationPickerView: View,
      ToolbarView: View,
      TransfersView: View {
    
    @ObservedObject private var content: Content
    
    private let factory: Factory
    private let config: Config
    
    public init(
        content: Content,
        factory: Factory,
        config: Config
    ) {
        self.content = content
        self.factory = factory
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: config.titleSpacing) {
                
                config.title.render()
                
                factory.makeOperationPickerView(content.operationPicker)
            }
            
            factory.makeTransfersView(content.transfers)
            
            factory.makeCategoryPickerView(content.categoryPicker)
        }
        .toolbar { factory.makeToolbarView(content.toolbar) }
    }
}

public extension PaymentsTransfersPersonalContentView {
    
    typealias Content = PaymentsTransfersPersonalContent<Toolbar, Transfers>
    typealias Factory = PaymentsTransfersPersonalViewFactory<CategoryPickerView, OperationPickerView, Toolbar, ToolbarView, Transfers, TransfersView>
    typealias Config = PaymentsTransfersPersonalViewConfig
}

// MARK: - Previews

#Preview {
    PaymentsTransfersPersonalContentView(
        content: .preview,
        factory: .init(
            makeCategoryPickerView: { _ in
                
                Text("Category Picker")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
            },
            makeOperationPickerView: { _ in
                
                Text("Operation Picker")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
            },
            makeToolbarView: {
                
                Text("Toolbar \(String(describing: $0))")
            },
            makeTransfersView: { transfers in
                
                VStack(spacing: 32) {
                    
                    ZStack {
                        
                        Color.black.opacity(0.75)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Text("TBD: Transfers \(String(describing: transfers))")
                            .foregroundColor(.white)
                            .font(.headline.bold())
                    }
                    .frame(height: 124)
                }
            }
        ),
        config: .preview
    )
}

private extension PaymentsTransfersPersonalContent
where Toolbar == PreviewToolbar,
      Transfers == PreviewTransfers {
    
    static var preview: PaymentsTransfersPersonalContent {
        
        return .init(
            categoryPicker: PreviewCategoryPicker(),
            operationPicker: PreviewOperationPicker(),
            toolbar: .init(),
            transfers: .init(),
            reload: {}
        )
    }
}

private final class PreviewCategoryPicker: CategoryPicker {}

private final class PreviewOperationPicker: OperationPicker {}

private final class PreviewToolbar {}

private final class PreviewTransfers {}
