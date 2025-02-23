//
//  ViewComponents+makeStatementDetailView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SharedConfigs
import SwiftUI
import UIPrimitives

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
    }
}

struct MakeStatementDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            view(.completed(.preview))
                .previewDisplayName("completed")
            
            view(.failure(NSError(domain: "Load Failure", code: -1)))
                .previewDisplayName("failure")
            
            view(.loading(nil))
                .previewDisplayName("loading")
            
            view(.pending)
                .previewDisplayName("pending")
        }
    }
    
    private static func view(
        _ fullDetails: OperationDetailDomain.State.ExtendedDetailsState
    ) -> some View {
        
        ViewComponents.preview.makeStatementDetailView(.init(
            model: .preview(
                basicDetails: .preview,
                fullDetails: fullDetails
            )
        ))
    }
}
