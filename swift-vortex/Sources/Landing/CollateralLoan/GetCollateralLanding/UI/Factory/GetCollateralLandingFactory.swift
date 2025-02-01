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
    public let makeImageViewWithMD5Hash: makeImageViewWithMD5Hash
    public let makeImageViewWithURL: makeImageViewWithURL
    
    public init(
        config: GetCollateralLandingConfig = .default,
        makeImageViewWithMD5Hash: @escaping makeImageViewWithMD5Hash,
        makeImageViewWithURL: @escaping makeImageViewWithURL
    ) {
        self.config = config
        self.makeImageViewWithMD5Hash = makeImageViewWithMD5Hash
        self.makeImageViewWithURL = makeImageViewWithURL
    }
}

public extension GetCollateralLandingFactory {
        
    typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    typealias makeImageViewWithMD5Hash = ShowcaseFactory.makeImageViewWithMD5Hash
    typealias makeImageViewWithURL = ShowcaseFactory.makeImageViewWithURL
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
