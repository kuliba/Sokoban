//
//  DayView.swift
//
//
//  Created by Дмитрий Савушкин on 17.05.2024.
//

import SwiftUI
import SharedConfigs

struct DayView: View {
    
    let state: State
    let config: Config
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(circleColor(state, config: config))
                .frame(width: 32, height: 32, alignment: .center)
            
            config.title.text(withConfig: config.titleConfig)
                .foregroundColor(textColor(state, config: config))
        }
    }
    
    private func circleColor(_ state: State, config: Config) -> Color {
        
        if state.isSelected {
        
            return config.selectBackgroundColor
        }
        
        if state.isToday {
            
            return config.todayBackgroundColor
        }
        
        return .clear
    }
    
    private func textColor(_ state: State, config: Config) -> Color {
        
        if state.isSelected {
        
            return config.selectTextColor
        }
        
        if state.isToday {
            
            return config.todayTextColor
        }
        
        return config.titleConfig.textColor
    }
    
    struct State {
        
        let isToday: Bool
        let isSelected: Bool
    }
    
    struct Config {
        
        let title: String
        let titleConfig: TextConfig
        
        let selectBackgroundColor: Color
        let todayBackgroundColor: Color
        
        let selectTextColor: Color
        let todayTextColor: Color
    }
}

#Preview {
    
    DayView(
        state: .init(isToday: true, isSelected: true),
        config: .init(
            title: "1",
            titleConfig: .init(textFont: .body, textColor: .red),
            selectBackgroundColor: .green,
            todayBackgroundColor: .blue,
            selectTextColor: .black,
            todayTextColor: .red
        ))
}
