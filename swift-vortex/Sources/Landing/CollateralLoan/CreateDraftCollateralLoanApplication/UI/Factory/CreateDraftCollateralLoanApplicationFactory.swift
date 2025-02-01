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
    
    public init(
        makeImageViewByMD5hash: @escaping MakeImageViewByMD5hash,
        makeImageViewByURL: @escaping MakeImageViewByURL
    ) {
        self.makeImageViewByMD5hash = makeImageViewByMD5hash
        self.makeImageViewByURL = makeImageViewByURL
    }
    
    public typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    public typealias MakeImageViewByMD5hash = ShowcaseFactory.MakeImageViewByMD5Hash
    public typealias MakeImageViewByURL = ShowcaseFactory.MakeImageViewByURL
    public typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    public typealias EventDispatcher = (Event) -> Void
}

// MARK: Preview helpers

public extension CreateDraftCollateralLoanApplicationFactory {
    
    static let preview = Self(
        makeImageViewByMD5hash: { _ in .preview },
        makeImageViewByURL: { _ in .preview }
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

extension TimedOTPInputViewModel {
    
    static let preview = TimedOTPInputViewModel(
        otpText: "44",
        timerDuration: 60,
        otpLength: 4,
        resend: {}
    )
}
