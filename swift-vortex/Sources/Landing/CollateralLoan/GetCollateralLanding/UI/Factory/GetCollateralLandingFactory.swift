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

    public let config: GetCollateralLandingConfig
    public let makeImageViewByMD5Hash: MakeImageViewByMD5Hash
    public let makeImageViewByURL: MakeImageViewByURL
    
    public init(
        config: GetCollateralLandingConfig = .default,
        makeImageViewByMD5Hash: @escaping MakeImageViewByMD5Hash,
        makeImageViewByURL: @escaping MakeImageViewByURL
    ) {
        self.config = config
        self.makeImageViewByMD5Hash = makeImageViewByMD5Hash
        self.makeImageViewByURL = makeImageViewByURL
    }
}

public extension GetCollateralLandingFactory {
        
    typealias MakeImageViewByMD5Hash = (String) -> UIPrimitives.AsyncImage
    typealias MakeImageViewByURL = (String) -> UIPrimitives.AsyncImage
}

extension GetCollateralLandingFactory {
    
    static let preview = Self(
        makeImageViewByMD5Hash: {
            _ in
                .init(
                    image: .iconPlaceholder,
                    publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
                )
        },
        makeImageViewByURL: { _ in
                .init(
                    image: .iconPlaceholder,
                    publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
                )
        }
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
