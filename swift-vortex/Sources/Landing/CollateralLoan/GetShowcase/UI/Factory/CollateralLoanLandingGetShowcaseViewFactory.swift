//
//  CollateralLoanLandingGetShowcaseViewFactory.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import Combine
import SwiftUI
import UIPrimitives
import OTPInputComponent

public struct CollateralLoanLandingGetShowcaseViewFactory {
    
    public let config: CollateralLoanLandingGetShowcaseViewConfig
    public let makeImageViewByMD5Hash: MakeImageViewByMD5Hash
    public let makeImageViewByURL: MakeImageViewByURL
    
    public init(
        config: CollateralLoanLandingGetShowcaseViewConfig = .base,
        makeImageViewByMD5Hash: @escaping MakeImageViewByMD5Hash,
        makeImageViewByURL: @escaping MakeImageViewByURL
    ) {
        self.config = config
        self.makeImageViewByMD5Hash = makeImageViewByMD5Hash
        self.makeImageViewByURL = makeImageViewByURL
    }
}
 
public extension CollateralLoanLandingGetShowcaseViewFactory {

    typealias IconView = UIPrimitives.AsyncImage
    typealias MakeImageViewByMD5Hash = (String) -> IconView
    typealias MakeImageViewByURL = (String) -> IconView
}

// MARK: Preview helpers

extension CollateralLoanLandingGetShowcaseViewFactory {
    
    static let preview = Self(
        makeImageViewByMD5Hash: { _ in .preview },
        makeImageViewByURL: { _ in .preview }
    )
}

extension UIPrimitives.AsyncImage {
    
    static let preview = UIPrimitives.AsyncImage(
        image: .iconPlaceholder,
        publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
