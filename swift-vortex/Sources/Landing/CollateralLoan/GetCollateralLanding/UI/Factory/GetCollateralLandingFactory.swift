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
    public let makeImageViewByMD5Hash: MakeImageViewByMD5Hash
    public let makeImageViewByURL: MakeImageViewByURL
    public let makeOTPView: MakeOTPView
    
    public init(
        config: GetCollateralLandingConfig = .default,
        makeImageViewByMD5Hash: @escaping MakeImageViewByMD5Hash,
        makeImageViewByURL: @escaping MakeImageViewByURL,
        makeOTPView: @escaping MakeOTPView
    ) {
        self.config = config
        self.makeImageViewByMD5Hash = makeImageViewByMD5Hash
        self.makeImageViewByURL = makeImageViewByURL
        self.makeOTPView = makeOTPView
    }
}

public extension GetCollateralLandingFactory {
        
    typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    typealias MakeImageViewByMD5Hash = ShowcaseFactory.MakeImageViewByMD5Hash
    typealias MakeImageViewByURL = ShowcaseFactory.MakeImageViewByURL
    typealias MakeOTPView = ShowcaseFactory.MakeOTPView
}

// MARK: Preview helpers

public extension GetCollateralLandingFactory {
    
    static let preview = Self(
        makeImageViewByMD5Hash: { _ in .preview },
        makeImageViewByURL: { _ in .preview },
        makeOTPView: { _ in
            
                .init(
                    viewModel: .preview,
                    config: .preview,
                    iconView: { .preview },
                    warningView: { .preview }
                )
        }
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
