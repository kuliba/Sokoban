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
    public let makeImageViewWithMD5Hash: makeImageViewWithMD5Hash
    public let makeImageViewWithURL: makeImageViewWithURL
    
    public init(
        config: CollateralLoanLandingGetShowcaseViewConfig = .base,
        makeImageViewWithMD5Hash: @escaping makeImageViewWithMD5Hash,
        makeImageViewWithURL: @escaping makeImageViewWithURL
    ) {
        self.config = config
        self.makeImageViewWithMD5Hash = makeImageViewWithMD5Hash
        self.makeImageViewWithURL = makeImageViewWithURL
    }
}
 
public extension CollateralLoanLandingGetShowcaseViewFactory {

    typealias IconView = UIPrimitives.AsyncImage
    typealias makeImageViewWithMD5Hash = (String) -> IconView
    typealias makeImageViewWithURL = (String) -> IconView
}

// MARK: Preview helpers

extension CollateralLoanLandingGetShowcaseViewFactory {
    
    static let preview = Self(
        makeImageViewWithMD5Hash: { _ in .preview },
        makeImageViewWithURL: { _ in .preview }
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
