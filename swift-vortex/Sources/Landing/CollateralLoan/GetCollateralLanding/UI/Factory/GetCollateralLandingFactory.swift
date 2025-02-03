//
//  GetCollateralLandingFactory.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import Combine
import SwiftUI
import UIPrimitives
import CollateralLoanLandingGetShowcaseUI

public struct GetCollateralLandingFactory {

    public let config: GetCollateralLandingConfig
    public let makeImageViewWithMD5Hash: MakeImageViewWithMD5Hash
    public let makeImageViewWithURL: MakeImageViewWithURL
    
    public init(
        config: GetCollateralLandingConfig = .default,
        makeImageViewWithMD5Hash: @escaping MakeImageViewWithMD5Hash,
        makeImageViewWithURL: @escaping MakeImageViewWithURL
    ) {
        self.config = config
        self.makeImageViewWithMD5Hash = makeImageViewWithMD5Hash
        self.makeImageViewWithURL = makeImageViewWithURL
    }
}

public extension GetCollateralLandingFactory {
        
    typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    typealias MakeImageViewWithMD5Hash = ShowcaseFactory.MakeImageViewWithMD5Hash
    typealias MakeImageViewWithURL = ShowcaseFactory.MakeImageViewWithURL
}

// MARK: Preview helpers

public extension GetCollateralLandingFactory {
    
    static let preview = Self(
        makeImageViewWithMD5Hash: { _ in .preview },
        makeImageViewWithURL: { _ in .preview }
    )
}

extension UIPrimitives.AsyncImage {
    
    static let preview = Self(
        image: .iconPlaceholder,
        publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
