//
//  OperatorView.swift
//
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

// TODO: improve naming, move to Design Components
public struct OperatorLabel<IconView>: View
where IconView: View {
    
    private let title: String
    private let subtitle: String?
    private let config: Config
    private let iconView: () -> IconView
    
    public init(
        title: String,
        subtitle: String?,
        config: Config,
        iconView: @escaping () -> IconView
    ) {
        self.title = title
        self.subtitle = subtitle
        self.config = config
        self.iconView = iconView
    }
    
    public init(
        title: String,
        subtitle: String?,
        config: Config,
        iconView: IconView
    ) {
        self.title = title
        self.subtitle = subtitle
        self.config = config
        self.iconView = { iconView }
    }
    
    public var body: some View {
        
        HStack(spacing: config.spacing) {
            
            iconView()
                .frame(width: 40, height: 40)
            
            titleView()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            chevronView()
        }
        .frame(height: config.height)
        .contentShape(Rectangle())
    }
}

public extension OperatorLabel {
    
    typealias Event = State
    typealias Config = OperatorLabelConfig
}

private extension OperatorLabel {
    
    func titleView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            title.text(withConfig: config.title)
            subtitle.map { $0.text(withConfig: config.subtitle) }
        }
        .lineLimit(1)
    }
    
    @ViewBuilder
    func chevronView() -> some View {
        
        config.chevron.map {
            
            $0.icon
                .foregroundColor($0.color)
                .frame(width: $0.size.width, height: $0.size.height)
        }
    }
}

// MARK: - Previews

struct OperatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            OperatorLabel(
                title: "ЖКУ Москвы (ЕИРЦ)",
                subtitle: "ИНН 7702070139",
                config: .preview,
                iconView: Color.pink
            )
            
            OperatorLabel(
                title: "ЖКУ Москвы (ЕИРЦ)",
                subtitle: "ИНН 7702070139",
                config: .previewWithChevron
                ,
                iconView: Color.pink
            )
        }
    }
}
