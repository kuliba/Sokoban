//
//  OperatorView.swift
//
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

public struct OperatorView: View {
    
    let `operator`: Operator
    let event: (Operator) -> Void
    let config: Config
    
    public init(
        `operator`: Operator,
        event: @escaping (Operator) -> Void,
        config: Config
    ) {
        self.`operator` = `operator`
        self.config = config
        self.event = event
    }
    
    public var body: some View {
        
        Button(action: { event(`operator`) }, label: label)
    }
}

public extension OperatorView {
    
    typealias Config = OperatorViewConfig
}

private extension OperatorView {
    
    func label() -> some View {
        
        HStack(spacing: 16) {
            
            image()
                .frame(width: 40, height: 40)
            
            title()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .frame(height: 46)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    func image() -> some View {
        
        if let image = `operator`.image {
            image.resizable()
        } else {
            Image.defaultIcon(
                backgroundColor: config.defaultIconBackgroundColor,
                foregroundColor: .white,
                icon: config.defaultIcon
            )
        }
    }
    
    @ViewBuilder
    func title() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(`operator`.title)
                .lineLimit(1)
                .font(config.titleFont)
                .foregroundColor(config.titleColor)
            
            if let description = `operator`.subtitle {
                
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
            operator: .init(
                id: "id",
                title: "ЖКУ Москвы (ЕИРЦ)",
                subtitle: "ИНН 7702070139",
                image: .init(systemName: "")
            ),
            event: { _ in },
            config: .init(
                titleFont: .title3,
                titleColor: .black,
                descriptionFont: .body,
                descriptionColor: .gray,
                defaultIconBackgroundColor: .black,
                defaultIcon: .init(systemName: "photo.artframe")
            )
        )
    }
}
