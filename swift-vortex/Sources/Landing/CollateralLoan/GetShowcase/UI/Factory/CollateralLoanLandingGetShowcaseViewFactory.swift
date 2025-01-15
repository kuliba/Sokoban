//
//  CollateralLoanLandingGetShowcaseViewFactory.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import SwiftUI
import UIPrimitives
import Combine

public struct CollateralLoanLandingGetShowcaseViewFactory {

    let config: CollateralLoanLandingGetShowcaseViewConfig = .base

    public let makeImageView: MakeImageView

    public init(
        makeImageView: @escaping MakeImageView
    ) {
        self.makeImageView = makeImageView
    }
    
    public typealias MakeImageView = (String) -> UIPrimitives.AsyncImage
}

extension CollateralLoanLandingGetShowcaseViewFactory {
    
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
