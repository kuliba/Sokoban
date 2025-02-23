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
        
        StatementDetailLayoutView(config: .iVortex) {
            
            makeC2GPaymentCompleteButtonsView(details.model)
        } content: {
            
            EmptyView()
        }
        .border(.red)
    }
}

struct StatementDetailLayoutView<Buttons: View, Content: View>: View {
    
    let config: Config
    let buttons: () -> Buttons
    let content: () -> Content
    
    var body: some View {
        
        VStack(spacing: config.spacing) {
            
            buttons()
            content()
        }
        .padding(config.insets)
    }
}

extension StatementDetailLayoutView {
    
    typealias Config = StatementDetailLayoutViewConfig
}

struct StatementDetailLayoutViewConfig: Equatable {
    
    let insets: EdgeInsets
    let spacing: CGFloat
}
