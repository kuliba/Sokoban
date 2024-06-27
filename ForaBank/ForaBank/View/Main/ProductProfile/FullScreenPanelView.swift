//
//  FullScreenPanelView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 27.06.2024.
//

import SwiftUI

struct FullScreenPanelView: View {
    
    let items: [PanelButton.Details]
    let event: (Event) -> Void
    let config: PanelView.Config = .default
    
    var body: some View {
        
        VStack {
            HStack(spacing: config.spacings.vstack) {
                ForEach(items, id: \.title, content: view)
            }
            .frame(maxWidth: .infinity)
            .padding(.leading, config.paddings.leading)
            .padding(.trailing, config.paddings.trailing)
            
            Spacer()
        }
    }
    
    private func view(details: PanelButton.Details) -> some View {
        
        PanelButton(
            details: details,
            event: { event(details.event()) },
            config: config)
    }
}

extension FullScreenPanelView {
    
    typealias Event = ProductProfileFlowManager.ButtonEvent
}
