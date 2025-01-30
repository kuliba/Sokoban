//
//  CreateDraftCollateralLoanApplicationFactory.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import CollateralLoanLandingGetShowcaseUI
import Combine
import OTPInputComponent
import SwiftUI
import UIPrimitives

public struct CreateDraftCollateralLoanApplicationFactory {
    
    public let makeImageViewByMD5hash: MakeImageViewByMD5hash
    public let makeImageViewByURL: MakeImageViewByURL
    public let makeOTPView: MakeOTPView
    
    public init(
        makeImageViewByMD5hash: @escaping MakeImageViewByMD5hash,
        makeImageViewByURL: @escaping MakeImageViewByURL,
        makeOTPView: @escaping MakeOTPView
    ) {
        self.makeImageViewByMD5hash = makeImageViewByMD5hash
        self.makeImageViewByURL = makeImageViewByURL
        self.makeOTPView = makeOTPView
    }
    
    public typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    public typealias MakeImageViewByMD5hash = ShowcaseFactory.MakeImageViewByMD5Hash
    public typealias MakeImageViewByURL = ShowcaseFactory.MakeImageViewByURL
    public typealias MakeOTPView = ShowcaseFactory.MakeOTPView
}

// MARK: Preview helpers

public extension CreateDraftCollateralLoanApplicationFactory {
    
    static let preview = Self(
        makeImageViewByMD5hash: { _ in .preview },
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
