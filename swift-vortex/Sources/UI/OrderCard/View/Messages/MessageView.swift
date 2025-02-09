//
//  MessageView.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import SwiftUI
import ToggleComponent

struct MessageView: View {
    
    let state: Bool
    let event: (Bool) -> Void
    let config: MessageViewConfig
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 16) {
            
            iconView()
            
            VStack(alignment: .leading, spacing: 6) {
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        
                        config.title.render()
                        
                        config.subtitle.render()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    toggleView()
                }
                
                config.description.render()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private extension MessageView {
    
    func iconView() -> some View {
        
        config.icon
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24, alignment: .center)
            .foregroundStyle(.gray)
    }
    
    func toggleView() -> some View {
        
        Toggle("", isOn: .init(
            get: { state },
            set: { event($0) }
        ))
        .toggleStyle(ToggleComponentStyle(config: config.toggle))
        .animation(.easeInOut, value: state)
    }
}

struct MessageView_Previews: PreviewProvider {
    
    private struct MessageWrapperView: View {
        
        @SwiftUI.State var state = false
        
        var body: some View {
            
            MessageView(state: state, event: { state = $0 }, config: .preview)
        }
    }
    
    static var previews: some View {
        
        MessageWrapperView()
    }
}

extension MessageViewConfig {
    
    static let preview: Self = .init(
        icon: .bolt,
        title: .init(
            text: "Информирование",
            config: .init(
                textFont: .headline,
                textColor: .green
            )
        ),
        subtitle: .init(
            text: "Пуш/смс расширенные",
            config: .init(
                textFont: .title3,
                textColor: .orange
            )
        ),
        description: .init(
            text: "Присылаем пуш-уведомления по операциям, если не доходят - отправляем смс. С тарифами за услугу согласен.",
            config: .init(
                textFont: .footnote,
                textColor: .pink
            )
        ),
        toggle: .init(colors: .init(on: .orange, off: .blue))
    )
}
