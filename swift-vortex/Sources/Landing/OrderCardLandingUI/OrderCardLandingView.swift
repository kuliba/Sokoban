//
//  LandingView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 05.12.2024.
//

import SwiftUI

public struct OrderCardLandingView: View {
    
    public typealias State = Landing
    public typealias Config = OrderCardLandingViewConfig
    
    private let state: State
    private let config: Config
    
    public init(
        state: State,
        config: Config
    ) {
        self.state = state
        self.config = config
    }
    
    public var body: some View {
        
        LazyVStack(spacing: 16) {
            
            HeaderView(
                model: state.header,
                config: config.headerConfig
            )
        }
    }
}

#Preview {
    
    OrderCardLandingView(
        state: .init(
            header: .preview
        ),
        config: .init(
            headerConfig: .preview
        )
    )
}

private extension HeaderView.Model {
    
    static let preview: Self = .init(
        title: "Карта МИР «Все включено»",
        options: [
            "кешбэк до 10 000 ₽ в месяц",
            "5% выгода при покупке топлива",
            "5% на категории сезона",
            "от 0,5% до 1% кешбэк на остальные покупки**"
        ],
        backgroundImage: Image("orderCardLanding")
    )
}

private extension HeaderViewConfig {
    
    static let preview: Self = .init(
        title: .init(
            textFont: .body,
            textColor: .black
        ),
        optionPlaceholder: .black
    )
}
