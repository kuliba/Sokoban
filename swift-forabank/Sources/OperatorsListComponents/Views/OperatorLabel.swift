//
//  OperatorView.swift
//
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

public struct OperatorLabel<IconView>: View
where IconView: View {
    
    private let title: String
    private let subtitle: String?
    private let config: Config
    private let iconView: IconView
    
    public init(
        title: String,
        subtitle: String?,
        config: Config,
        iconView: IconView
    ) {
        self.title = title
        self.subtitle = subtitle
        self.config = config
        self.iconView = iconView
    }
    
    public var body: some View {
        
        HStack(spacing: 16) {
            
            iconView
                .frame(width: 40, height: 40)
            
            titleView()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .frame(height: 46)
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
}

// MARK: - Previews

struct OperatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OperatorLabel(
            title: "ЖКУ Москвы (ЕИРЦ)",
            subtitle: "ИНН 7702070139",
            config: .preview,
            iconView: Text("Icon View")
        )
    }
}
