//
//  LandingView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 05.12.2024.
//

import SwiftUI
import DropDownTextListComponent

public struct OrderCardLandingView: View {
    
    public typealias State = Landing
    public typealias Config = OrderCardLandingViewConfig
    
    private let state: State
    private let config: Config
    private let factory: ImageViewFactory
    
    public init(
        state: State,
        config: Config,
        factory: ImageViewFactory
    ) {
        self.state = state
        self.config = config
        self.factory = factory
    }
    
    public var body: some View {
        
        LazyVStack(spacing: 16) {
            
            HeaderView(
                model: state.header,
                config: config.headerConfig,
                imageFactory: factory
            )
            
            DropDownTextListView(
                config: config.dropDownConfig,
                list: state.dropDownList
            )
        }
    }
}

#Preview {
    
    OrderCardLandingView(
        state: .init(
            dropDownList: .preview,
            header: .preview
        ),
        config: .init(
            dropDownConfig: .preview,
            headerConfig: .preview
        ),
        factory: .default
    )
}

private extension DropDownTextList {
    
    static let preview: Self = .init(
        title: "title",
        items: [.init(
            title: "title",
            subTitle: "subtitle"
        )]
    )
}

private extension DropDownTextListConfig {
    
    static let preview: Self = .init(
        cornerRadius: 12,
        chevronDownImage: .bolt,
        layouts: .init(
            horizontalPadding: 16,
            verticalPadding: 15
        ),
        colors: .init(
            divider: .gray,
            background: .accentColor
        ),
        fonts: .init(
            title: .init(textFont: .body, textColor: .red),
            itemTitle: .init(textFont: .body, textColor: .purple),
            itemSubtitle: .init(
                textFont: .body,
                textColor: .black
            )
        )
    )
}

extension HeaderView.Model {
    
    static let preview: Self = .init(
        title: "Карта МИР «Все включено»",
        options: [
            "кешбэк до 10 000 ₽ в месяц",
            "5% выгода при покупке топлива",
            "5% на категории сезона",
            "от 0,5% до 1% кешбэк на остальные покупки**"
        ],
        md5Hash: "orderCardLanding"
    )
}

private extension HeaderViewConfig {
    
    static let preview: Self = .init(
        title: .init(
            textFont: .body,
            textColor: .black
        ),
        optionPlaceholder: .black,
        layout: .init(
            textViewLeadingPadding: 16,
            textViewTrailingPadding: 15
        )
    )
}
