//
//  InputView.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

import SwiftUI

struct InputView<Icon, IconView: View>: View {
    
    let state: State
    let event: (Event) -> Void
    let config: InputViewConfig
    let iconView: () -> IconView
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(state.settings.title)
            Text(state.settings.subtitle)
            
            HStack {
                
                iconView()
                
                TextField(
                    state.settings.hint,
                    text: .init(
                        get: { state.dynamic.value },
                        set: { event(.edit($0)) }
                    )
                )
            }
            
            state.dynamic.warning.map { Text($0).foregroundColor(.red) }
            Text(state.settings.hint)
        }
    }
}

extension InputView {
    
    typealias State = InputState<Icon>
    typealias Event = InputEvent
}

// MARK: - Previews

struct InputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InputView(
            state: .preview,
            event: { _ in },
            config: .preview,
            iconView: { Text("Icon view") }
        )
    }
}

extension InputState where Icon == String {
    
    static var preview: Self = .init(
        dynamic: .preview,
        settings: .preview
    )
}

private extension InputState.Dynamic where Icon == String {
    
    static var preview: Self = .init(
        value: "some value",
        warning: nil
    )
}

private extension InputState.Settings where Icon == String {
    
    static var preview: Self = .init(
        hint: "hint here",
        icon: "inputIcon",
        keyboard: .default,
        title: "input title",
        subtitle: "input subtitle"
    )
}

extension InputViewConfig {
    
    static var preview: Self = .init()
}
