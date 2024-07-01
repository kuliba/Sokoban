//
//  PanelView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.04.2024.
//

import SwiftUI

struct PanelView: View {
    
    let items: [PanelButtonDetails]
    let event: (Event) -> Void
    let config: Config = .default
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: config.spacings.vstack) {
            ForEach(items, id: \.title, content: view)
        }
        .frame(maxWidth: .infinity)
        .padding(.leading, config.paddings.leading)
        .padding(.trailing, config.paddings.trailing)
    }
    
    private func view(details: PanelButtonDetails) -> some View {
        
        PanelButton(
            details: details,
            event: { event(details.event()) },
            config: config)
    }
}

extension PanelView {
    
    typealias Event = ProductProfileFlowManager.ButtonEvent
}
