//
//  QRMappingFailureView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.01.2025.
//

import RxViewModel
import SwiftUI

struct QRMappingFailureView: View {
    
    let binder: Domain.Binder
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            Image(.ic24MoreHorizontal)
                .resizable()
                .frame(width: 200, height: 200)
                .navigationBarWithBack(
                    title: "",
                    dismiss: { event(.dismiss) }
                )
                .navigationDestination(
                    destination: state.navigation?.destination,
                    content: destinationView
                )
        }
    }
}

extension QRMappingFailureView {
    
    typealias Domain = QRMappingFailureDomain
}

private extension QRMappingFailureView {
    
    @ViewBuilder
    func destinationView(
        destination: Domain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case .manualSearch:
            Text("TBD: manualSearch")
            
        case .detailPayment:
            Text("TBD: detailPayment")
        }
    }
}

extension QRMappingFailureDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case .back:          return nil
        case .detailPayment: return .detailPayment
        case .manualSearch:  return.manualSearch
        }
    }
    
    enum Destination {
        
        case manualSearch, detailPayment
    }
}

extension QRMappingFailureDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .manualSearch:  return .manualSearch
        case .detailPayment: return .detailPayment
        }
    }
    
    enum ID: Hashable {
        
        case manualSearch, detailPayment
    }
}
