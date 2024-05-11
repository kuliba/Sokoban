//
//  OperatorView.swift
//
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

public struct OperatorView<Icon, IconView>: View
where IconView: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let makeIconView: MakeIconView
    
    public init(
        state: State,
        event: @escaping (State) -> Void,
        config: Config,
        makeIconView: @escaping MakeIconView
    ) {
        self.state = state
        self.config = config
        self.event = event
        self.makeIconView = makeIconView
    }
    
    public var body: some View {
        
        Button(action: { event(state) }, label: label)
    }
}

public extension OperatorView {
    
    typealias MakeIconView = (Icon) -> IconView
    
    typealias State = Operator<Icon>
    typealias Event = State
    typealias Config = OperatorViewConfig
}

private extension OperatorView {
    
    func label() -> some View {
        
        HStack(spacing: 16) {
            
            makeIconView(state.icon)
                .frame(width: 40, height: 40)
            
            title()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .frame(height: 46)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    func title() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(state.title)
                .lineLimit(1)
                .font(config.titleFont)
                .foregroundColor(config.titleColor)
            
            if let description = state.subtitle {
                
                Text(description)
                    .lineLimit(1)
                    .font(config.descriptionFont)
                    .foregroundColor(config.descriptionColor)
            }
        }
    }
}

// MARK: - Previews

struct OperatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OperatorView(
            state: .init(
                id: "id",
                title: "ЖКУ Москвы (ЕИРЦ)",
                subtitle: "ИНН 7702070139",
                icon: "abc"
            ),
            event: { _ in },
            config: .preview,
            makeIconView: { Text("Icon View \($0)") }
        )
    }
}
