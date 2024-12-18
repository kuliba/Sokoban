//
//  GetCollateralLandingFactory.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import Combine
import SwiftUI
import UIPrimitives

struct GetCollateralLandingFactory {

    let config: GetCollateralLandingConfig
    let makeIconView: MakeIconView
    let makeImageView: MakeImageView
    
    public init(
        config: GetCollateralLandingConfig = .default,
        makeIconView: @escaping MakeIconView,
        makeImageView: @escaping MakeImageView
    ) {
        self.config = config
        self.makeIconView = makeIconView
        self.makeImageView = makeImageView
    }
}

extension GetCollateralLandingFactory {
        
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    typealias MakeImageView = (String) -> UIPrimitives.AsyncImage
}

extension GetCollateralLandingFactory {
    
    static let preview = Self(
        makeIconView: { _ in .init(
            image: .iconPlaceholder,
            publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
        )},
        makeImageView: { _ in .init(
            image: .iconPlaceholder,
            publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
        )}
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
