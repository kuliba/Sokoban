//
//  GetCollateralLandingFactory.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import Combine
import SwiftUI
import UIPrimitives

public struct GetCollateralLandingFactory {

    let config: GetCollateralLandingConfig
    let makeImageView: MakeImageView
    
    public init(
        config: GetCollateralLandingConfig = .default,
        makeImageView: @escaping MakeImageView
    ) {
        self.config = config
        self.makeImageView = makeImageView
    }
}

public extension GetCollateralLandingFactory {
        
    typealias MakeImageView = (String) -> UIPrimitives.AsyncImage
}

extension GetCollateralLandingFactory {
    
    static let preview = Self(
        makeImageView: { _ in .init(
            image: .iconPlaceholder,
            publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
        )}
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
