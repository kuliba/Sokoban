//
//  FilterOptionButtonView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import SwiftUI
import SharedConfigs

struct FilterOptionButtonView: View {
    
    @State var state: FilterOptionState
    let tappedAction: () -> Void
    let config: Config
    
    var body: some View {
        
        Button {
            
            tappedAction()
            
        } label: {
            
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

extension FilterOptionButtonView {
    
    struct FilterOptionState: Equatable {
      
      let isSelected: Bool
    }

    struct Config {
        
        let title: String
        let titleConfig: TextConfig
        let selectedConfig: TextConfig
        
    }
}

#Preview {
    
    Group {
        
        FilterOptionButtonView(
            state: .init(isSelected: true),
            tappedAction: {},
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
