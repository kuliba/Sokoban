//
//  ViewComponents+searchByUINView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import RxViewModel
import SwiftUI

extension ViewComponents {
    
    func searchByUINView(
        _ binder: SearchByUINDomain.Binder
    ) -> some View {
        
        searchByUINFlowView(flow: binder.flow) {
            
            VStack(spacing: 16) {
                
                Text("TBD: Search by UIN")
                    .font(.headline)
                
                Button("connectivityFailure") {
                    
                    binder.flow.event(.select(.uin(.init(value: "connectivityFailure"))))
                }
                
                Button("serverFailure") {
                    
                    binder.flow.event(.select(.uin(.init(value: "serverFailure"))))
                }
                
                Button("success") {
                    
                    binder.flow.event(.select(.uin(.init(value: UUID().uuidString))))
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.bordered)
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
    
    func searchByUINFlowView(
        flow: SearchByUINDomain.Flow,
        contentView: @escaping () -> some View
    ) -> some View {
        
        RxWrapperView(model: flow) { state, event in
            
            contentView()
               // .disablingLoading(isLoading: state.isLoading)
        }
    }
}
