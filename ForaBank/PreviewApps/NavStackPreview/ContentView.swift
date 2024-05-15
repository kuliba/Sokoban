//
//  ContentView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Combine
import CombineSchedulers
import RxViewModel
import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    var body: some View {
        
        let initialState: UtilityServicePaymentFlowState<String> = .init(
            operatorPickerState: .init(
                lastPayments: .preview,
                operators: .preview
            ),
            destination: nil
        )
        
        NavigationView {
            
            FlowView {
                
                FlowComposer.makeUtilityServicePaymentFlowView(
                    initialState: initialState,
                    config: .preview
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
