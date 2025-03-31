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
    let isFailure: Bool
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 6) {
            
            HStack(alignment: .center, spacing: config.spacing) {
                
                iconView(isLoading)
                messageWithToggle()
            }
            
            config.description.text.string(isLoading || isFailure)
                .text(withConfig: config.description.config)
                .modifier(placeholderModifier())
                .padding(.leading, config.iconSize.width + config.spacing)
        }
    }
    
    private func placeholderModifier() -> PlaceholderModifier {
        
        .init(
            colors: config.colors,
            cornerRadius: config.iconSize.height / 2,
            isFailure: isFailure,
            isLoading: isLoading
        )
    }
    
    private func messageWithToggle() -> some View {
        
        HStack {
            
            message()
            toggleView()
                .disabled(isLoading)
        }
    }
    
    private func message() -> some View {
        
        VStack(alignment: .leading, spacing: 6) {
            
            config.title.text.string(isLoading || isFailure)
                .text(withConfig: config.title.config)
                .modifier(placeholderModifier())

            config.subtitle.text.string(isLoading || isFailure)
                .text(withConfig: config.subtitle.config)
                .modifier(placeholderModifier())

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension TopUpView {
    
    @ViewBuilder
    func iconView(
        _ isLoading: Bool
    ) -> some View {
       
        if isLoading || isFailure {
            Circle()
                .fill(config.placeholder)
                .frame(config.iconSize)
                .shimmering(active: isLoading)
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
            
            TopUpView(
                state: state,
                event: { state.isOn = $0 },
                config: .preview,
                isLoading: true,
                isFailure: false
            )
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
        placeholder: .gray,
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
        ), 
        shimmering: .gray
    )
}

private extension TopUpViewConfig {
    
    var colors: PlaceholderModifier.Colors {
        .init(
            placeholder: placeholder,
            shimmering: shimmering
        )
    }
}
