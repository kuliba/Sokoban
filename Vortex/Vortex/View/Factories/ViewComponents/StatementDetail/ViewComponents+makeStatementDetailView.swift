//
//  ViewComponents+makeStatementDetailView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SharedConfigs
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeStatementDetailView(
        _ details: StatementDetails
    ) -> some View {
        
        StatementDetailLayoutView(config: .iVortex) {
            
            makeC2GPaymentCompleteButtonsView(details.model)
        } content: {
            
            EmptyView()
        }
        .border(.red)
    }
}
