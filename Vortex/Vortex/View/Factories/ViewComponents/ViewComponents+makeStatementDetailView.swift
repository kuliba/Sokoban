//
//  ViewComponents+makeStatementDetailView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeStatementDetailView(
        _ details: StatementDetails
    ) -> some View {
        
        VStack {
            
            makeC2GPaymentCompleteButtonsView(details.model)
        }
        .padding(.vertical, 40)
        .edgesIgnoringSafeArea(.bottom)
    }
}
