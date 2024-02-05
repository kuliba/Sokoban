//
//  FastPaymentsSettingsView.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import SwiftUI

public struct FastPaymentsSettingsView: View {
    
    let settingsResult: UserPaymentSettingsResult?
    let event: (FastPaymentsSettingsEvent) -> Void
    let config: FastPaymentsSettingsConfig
    
    public init(
        settingsResult: UserPaymentSettingsResult?,
        event: @escaping (FastPaymentsSettingsEvent) -> Void,
        config: FastPaymentsSettingsConfig
    ) {
        self.settingsResult = settingsResult
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        switch settingsResult {
        case .none, .failure:
            Color.clear
            
        case let .success(.contracted(contractDetails)):
            switch contractDetails.paymentContract.contractStatus {
            case .active:
                ActiveContractView(
                    contractDetails: contractDetails,
                    event: event,
                    config: config.activeContract
                )
                
            case .inactive:
                inactiveContractView()
            }
            
        case .success(.missingContract):
            inactiveContractView()
        }
    }
    
    private func inactiveContractView() -> some View {
        
        InactiveContractView(
            action: { event(.contract(.activateContract)) },
            config: config.inactiveContract
        )
    }
}

struct FastPaymentsSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        fastPaymentsSettingsView(.success(.active()))
            .previewDisplayName("active")
        
        VStack(content: other)
            .previewDisplayName("non-active")
        
        other()
    }
    
    private static func other() -> some View {
        
        Group {
            
            fastPaymentsSettingsView(.success(.inactive()))
                .previewDisplayName("inactive")
            
            fastPaymentsSettingsView(.success(.missingContract()))
                .previewDisplayName("missing")
            
            fastPaymentsSettingsView(.none)
                .previewDisplayName("nil")
            
            fastPaymentsSettingsView(.failure(.connectivityError))
                .previewDisplayName("connectivityError")
            
            fastPaymentsSettingsView(.failure(.serverError("Server Error (#8765).")))
                .previewDisplayName("serverError")
        }
    }
    
    private static func fastPaymentsSettingsView(
        _ settingsResult: UserPaymentSettingsResult?
    ) -> some View {
        
        FastPaymentsSettingsView(
            settingsResult: settingsResult,
            event: { _ in },
            config: .preview
        )
    }
}
