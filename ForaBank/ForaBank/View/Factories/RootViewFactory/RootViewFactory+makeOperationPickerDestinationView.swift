//
//  RootViewFactory+makeOperationPickerDestinationView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

import SwiftUI

extension RootViewFactory {
    
    @ViewBuilder
    func makeOperationPickerDestinationView(
        destination: OperationPickerDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .exchange(currencyWalletViewModel):
            components.makeCurrencyWalletView(currencyWalletViewModel)
            
        case let .latest(latest):
            Text("TBD: destination " + String(describing: latest))
            
        case let .status(operationPickerFlowStatus):
            EmptyView()
            
        case let .templates(templates):
            Text("TBD: destination " + String(describing: templates))
        }
    }
}
