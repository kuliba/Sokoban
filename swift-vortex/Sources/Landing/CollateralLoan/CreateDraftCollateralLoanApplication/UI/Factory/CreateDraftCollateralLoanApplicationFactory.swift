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
    
    public let makeImageViewWithMD5Hash: MakeImageViewWithMD5Hash
    public let makeImageViewWithURL: MakeImageViewWithURL
    
    public init(
        makeImageViewWithMD5Hash: @escaping MakeImageViewWithMD5Hash,
        makeImageViewWithURL: @escaping MakeImageViewWithURL
    ) {
        self.makeImageViewWithMD5Hash = makeImageViewWithMD5Hash
        self.makeImageViewWithURL = makeImageViewWithURL
    }
    
    public typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    public typealias MakeImageViewWithMD5Hash = ShowcaseFactory.MakeImageViewWithMD5Hash
    public typealias MakeImageViewWithURL = ShowcaseFactory.MakeImageViewWithURL
    public typealias Domain = CreateDraftCollateralLoanApplicationDomain
    public typealias Event = Domain.Event
    public typealias EventDispatcher = (Event) -> Void
}

// MARK: Preview helpers

public extension CreateDraftCollateralLoanApplicationFactory {
    
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

extension TimedOTPInputViewModel {
    
    static let preview = TimedOTPInputViewModel(
        otpText: "44",
        timerDuration: 60,
        otpLength: 4,
        resend: {}
    )
}
