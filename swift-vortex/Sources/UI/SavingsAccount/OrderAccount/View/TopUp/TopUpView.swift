//
//  TopUpView.swift
//
//
//  Created by Andryusina Nataly on 23.02.2025.
//

import SwiftUI
import ToggleComponent
import UIPrimitives

struct TopUpView: View {
    
    let state: TopUp
    let event: (Bool) -> Void
    let config: TopUpViewConfig
    let isLoading: Bool
    
    var body: some View {
        
        HStack(alignment: .top, spacing: config.spacing) {
            
            iconView(isLoading)
            
            VStack(alignment: .leading, spacing: 6) {
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        
                        config.title.text.string(isLoading).text(withConfig: config.title.config)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        config.subtitle.text.string(isLoading).text(withConfig: config.subtitle.config)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    toggleView()
                        .disabled(isLoading)
                }
                
                config.description.text.string(isLoading).text(withConfig: config.description.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private extension TopUpView {
    
    @ViewBuilder
    func iconView(
        _ isLoading: Bool
    ) -> some View {
       
        if isLoading {
            Circle()
                .frame(config.iconSize)
                .shimmering()
        }
        else {
            config.icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(config.iconSize)
                .foregroundStyle(.gray)
        }
    }
    
    func toggleView() -> some View {
        
        Toggle("", isOn: .init(
            get: { state.isOn },
            set: { event($0) }
        ))
        .toggleStyle(ToggleComponentStyle(config: config.toggle))
        .animation(.easeInOut, value: state)
    }
}

struct TopUpView_Previews: PreviewProvider {
    
    private struct TopUpWrapperView: View {
        
        @State var state = TopUp(isOn: true)
        
        var body: some View {
            
            TopUpView(state: state, event: { state.isOn = $0 }, config: .preview, isLoading: false)
        }
    }
    
    static var previews: some View {
        
        TopUpWrapperView()
    }
}

extension TopUpViewConfig {
    
    static let preview: Self = .init(
        description: .init(
            text: "Пополнение доступно без комиссии",
        config:.init(
            textFont: .body,
            textColor: .blue
        )),
        icon: .bolt,
        iconSize: .init(width: 24, height: 24), 
        spacing: 16,
        subtitle: .init(
            text: "Пополнить сейчас",
            config: .init(
                textFont: .title3,
                textColor: .orange
            )
        ),
        title: .init(
            text: "Хотите пополнить счет,",
            config: .init(
                textFont: .headline,
                textColor: .green
            )
        ),
        toggle: .init(
            colors: .init(
                on: .orange,
                off: .blue
            )
        )
    )
}
