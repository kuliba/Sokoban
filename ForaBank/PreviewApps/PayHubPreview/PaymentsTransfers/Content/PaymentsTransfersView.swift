//
//  PaymentsTransfersView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct PaymentsTransfersView<CategoryPicker, CategoryPickerView, PayHub, PayHubView>: View
where CategoryPicker: Loadable,
      CategoryPickerView: View,
      PayHub: Loadable,
      PayHubView: View {
    
    @StateObject var model: Model
    
    let factory: Factory
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Button("Reload | to be replaced with \"swipe to refresh\")", action: model.reload)
            
            factory.makePayHubView(model.operationPicker)
            
            factory.makeCategoryPickerView(model.categoryPicker)
            
            Spacer()
        }
        .padding()
    }
}

extension PaymentsTransfersModel
where CategoryPicker: Loadable,
      OperationPicker: Loadable {
    
    func reload() {
        
        categoryPicker.load()
        operationPicker.load()
    }
}

extension PaymentsTransfersView {
    
    typealias Model = PaymentsTransfersModel<CategoryPicker, PayHub>
    typealias Factory = PaymentsTransfersViewFactory<CategoryPicker, CategoryPickerView, PayHub, PayHubView>
}

#Preview {
    PaymentsTransfersView(
        model: .preview,
        factory: .init(
            makeCategoryPickerView: { (categoryPicker: PreviewCategoryPicker) in
                
                Text("TBD")
                    .padding()
                    .background(Color.orange.opacity(0.1))
            },
            makePayHubView: { (payHub: PreviewPayHub) in
                
                Text("TBD")
                    .padding()
                    .background(Color.orange.opacity(0.1))
            }
        )
    )
}

private extension PaymentsTransfersModel
where CategoryPicker == PreviewCategoryPicker,
      OperationPicker == PreviewPayHub {
    
    static var preview: PaymentsTransfersModel {
        
        return .init(
            categoryPicker: .init(),
            operationPicker: .init()
        )
    }
}

private final class PreviewCategoryPicker: Loadable {
    
    func load() {}
}

private final class PreviewPayHub: Loadable {
    
    func load() {}
}
