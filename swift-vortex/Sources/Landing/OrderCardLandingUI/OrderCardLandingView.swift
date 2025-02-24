//
//  LandingView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 05.12.2024.
//

import SwiftUI
import HeaderLandingComponent
import DropDownTextListComponent

public struct OrderCardLandingView: View {
    
    public typealias Config = OrderCardLandingViewConfig
    
    private let landing: Landing
    private let config: Config
    private let factory: ImageViewFactory
    
    public init(
        landing: Landing,
        config: Config,
        factory: ImageViewFactory
    ) {
        self.landing = landing
        self.config = config
        self.factory = factory
    }
    
    public var body: some View {
        
        HeaderView(
            header: landing.header,
            config: config.headerConfig,
            imageFactory: .init(makeIconView: factory.makeIconView)
        )
    }
}

#Preview {
    
    OrderCardLandingView(
        landing: .init(
            header: .preview
        ),
        config: .init(
            headerConfig: .preview
        ),
        factory: .default
    )
}

extension Header {
    
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
                circleRadius: 5,
                horizontalSpacing: 5,
                optionWidth: 150
            ),
            textViewLeadingPadding: 16,
            textViewOptionsVerticalSpacing: 26,
            textViewTrailingPadding: 15,
            textViewVerticalSpacing: 20
        )
    )
}
