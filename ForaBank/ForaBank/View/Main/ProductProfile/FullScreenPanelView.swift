//
//  FullScreenPanelView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 27.06.2024.
//

import SwiftUI

struct FullScreenPanelView: View {
    
    let items: [PanelButtonDetails]
    let event: (Event) -> Void
    let config: FullScreenPanelView.Config = .default
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                ForEach(items, id: \.title, content: view)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Просмотр и изменение лимитов")
                .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, config.paddings.horizontal)
        .padding(.top, config.paddings.top)
    }
    
    private func view(details: PanelButtonDetails) -> some View {
        
        HorizontalPanelButton(
            details: details,
            event: { event(details.event()) },
            config: config)
    }
}

extension FullScreenPanelView {
    
    typealias Event = ProductProfileFlowManager.ButtonEvent
}
