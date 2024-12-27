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
    let makeIconView: MakeIconView
    let makeImageView: MakeImageView

    public init(
        makeIconView: @escaping MakeIconView,
        makeImageView: @escaping MakeImageView
    ) {
        self.makeIconView = makeIconView
        self.makeImageView = makeImageView
    }
    
    public typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    public typealias MakeImageView = (String) -> UIPrimitives.AsyncImage
}

extension CollateralLoanLandingGetShowcaseViewFactory {
    
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
