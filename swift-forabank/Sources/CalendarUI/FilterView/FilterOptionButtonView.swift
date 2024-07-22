//
//  FilterOptionButtonView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import SwiftUI
import SharedConfigs

struct FilterOptionButtonView: View {
    
    @State var isSelected: Bool
    let tappedAction: () -> Void
    let config: Config
    
    var body: some View {
        
        Button {
            
            tappedAction()
            isSelected.toggle()
            
        } label: {
            
            config.title.text(withConfig: config.titleConfig)
                .padding(.vertical, 7.5)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .active(if: isSelected)
            
            config.title.text(withConfig: config.selectedConfig)
                .padding(.vertical, 7.5)
                .padding(.horizontal, 8)
                .background(Color.black)
                .cornerRadius(20)
                .active(if: !isSelected)
        }
    }
}

extension FilterOptionButtonView {
    
    struct Config {
        
        let title: String
        let titleConfig: TextConfig
        let selectedConfig: TextConfig
        
    }
}

#Preview {
    
    Group {
        
        FilterOptionButtonView(
            isSelected: true,
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
