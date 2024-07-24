//
//  FilterOptionButtonView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import SwiftUI
import SharedConfigs

struct FilterOptionButtonView: View {
    
    typealias State = FilterOptionButtonState
    typealias Event = FilterOptionButtonEvent
    typealias Config = FilterOptionButtonConfig
    
    var state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        Button(action: { event(.onTap) }) {
            
            config.title.text(withConfig: config.titleConfig)
                .padding(.vertical, 7.5)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .active(if: state.isSelected)
            
            config.title.text(withConfig: config.selectedConfig)
                .padding(.vertical, 7.5)
                .padding(.horizontal, 8)
                .background(Color.black)
                .cornerRadius(20)
                .active(if: !state.isSelected)
        }
    }
}

#Preview {
    
    Group {
        
        FilterOptionButtonView(
            state: .init(isSelected: true),
            event: { _ in },
            config: .init(
                title: "Списание",
                titleConfig: .init(
                    textFont: .body,
                    textColor: .black
                ),
                selectedConfig: .init(
                    textFont: .body,
                    textColor: .white
                ))
        )
    }
}
