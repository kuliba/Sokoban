//
//  PaymentsTransfersView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

struct PaymentsTransfersView<PayHub, PayHubView>: View
where PayHub: Loadable,
      PayHubView: View {
    
    @StateObject var model: Model
    let factory: Factory
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Button("Reload | to be replaced with \"swipe to refresh\")", action: model.reload)
            
            factory.makePayHubView(model.payHub)
            
            Spacer()
        }
        .padding()
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
        
        return .init(payHub: .init())
    }
}

private final class PreviewPayHub: Loadable {
    
    func load() {}
}
