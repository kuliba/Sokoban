//
//  LandingView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 05.12.2024.
//

import SwiftUI
import HeaderLandingComponent

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
        
        HeaderView(
            model: state.header,
            config: config.headerConfig,
            imageFactory: factory
        )
    }
}

#Preview {
    
    OrderCardLandingView(
        state: .init(
            header: .preview
        ),
        config: .init(
            headerConfig: .preview
        ),
        factory: .default
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
        option: .init(textFont: .body, textColor: .red),
        layout: .init(
            itemOption: .init(
                horizontalSpacing: 5
            ),
            textViewLeadingPadding: 16,
            textViewOptionsVerticalSpacing: 26,
            textViewTrailingPadding: 15,
            textViewVerticalSpacing: 20
        )
    )
}
