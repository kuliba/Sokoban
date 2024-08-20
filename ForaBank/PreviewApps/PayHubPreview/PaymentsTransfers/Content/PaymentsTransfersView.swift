//
//  PaymentsTransfersView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct PaymentsTransfersView<PayHub, PayHubView>: View
where PayHub: Loadable,
      PayHubView: View {
    
    @StateObject var model: Model
    let factory: Factory
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Button("Reload | to be replaced with \"swipe to refresh\")", action: model.reload)
            
            factory.makePayHubView(model.payHubPicker)
            
            Spacer()
        }
        .padding()
    }
}

extension PaymentsTransfersModel where PayHubPicker: Loadable {
    
    func reload() {
        
        payHubPicker.load()
    }
}

extension PaymentsTransfersView {
    
    typealias Model = PaymentsTransfersModel<PayHub>
    typealias Factory = PaymentsTransfersViewFactory<PayHub, PayHubView>
}

#Preview {
    PaymentsTransfersView(
        model: .preview,
        factory: .init(
            makePayHubView: { (payHub: PreviewPayHub) in
                
                Text("TBD")
                    .padding()
                    .background(Color.orange.opacity(0.1))
            }
        )
    )
}

private extension PaymentsTransfersModel
where PayHubPicker == PreviewPayHub {
    
    static var preview: PaymentsTransfersModel {
        
        return .init(payHubPicker: .init())
    }
}

private final class PreviewPayHub: Loadable {
    
    func load() {}
}
