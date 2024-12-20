//
//  MPMapView_Previews.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

import SwiftUI

struct MPMapView_Previews: PreviewProvider {
    
    private struct MPMapDemo: View {
                
        @State private var state: ComponentState
        
        @State private var showingPayments = false
        @State private var showingContinue = false
        
        let model: PickerWithPreviewModel
        
        init(
            initialState: ComponentState,
            options: [SubscriptionType: [OptionWithMapImage]]
        ) {
            _state = .init(initialValue: initialState)
            self.model = .init(state: initialState, options: options)
        }
        
        var body: some View {
            
            NavigationView {
                
                PickerWithPreviewContainerView(
                    model: model,
                    viewConfig: .`defaulf`,
                    checkUncheckImage: .`default`,
                    paymentAction: { showingPayments = true },
                    continueAction: { showingContinue = true }
                )
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        
                        Image(systemName: "pencil")
                    }
                }

                .alert(isPresented: $showingContinue) {
                    .init(title: Text("Continue button was tapped"))
                }
                .sheet(isPresented: $showingPayments) {
                    let _ = print("Payment tap")
                    Text("Payment flow")
                }
            }
        }
    }
    
    static var previews: some View {
        
        MPMapDemo(
            initialState: .monthlyOne,
            options: .all
        )
        .previewDisplayName("MPMapDemo: Preview")
    }
}
