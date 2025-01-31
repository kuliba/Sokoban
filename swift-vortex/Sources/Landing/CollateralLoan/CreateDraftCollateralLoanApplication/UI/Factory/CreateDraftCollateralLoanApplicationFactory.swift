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
    
    public let makeImageViewWithMD5Hash: makeImageViewWithMD5Hash
    public let makeImageViewWithURL: makeImageViewWithURL
//    public let makeOTPViewModel: MakeOTPViewModel
    
    public init(
        makeImageViewWithMD5Hash: @escaping makeImageViewWithMD5Hash,
        makeImageViewWithURL: @escaping makeImageViewWithURL
//        makeOTPViewModel: @escaping MakeOTPViewModel
    ) {
        self.makeImageViewWithMD5Hash = makeImageViewWithMD5Hash
        self.makeImageViewWithURL = makeImageViewWithURL
//        self.makeOTPViewModel = makeOTPViewModel
    }
    
    public typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    public typealias makeImageViewWithMD5Hash = ShowcaseFactory.makeImageViewWithMD5Hash
    public typealias makeImageViewWithURL = ShowcaseFactory.makeImageViewWithURL
    public typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    public typealias EventDispatcher = (Event) -> Void
//    public typealias MakeOTPViewModel = (Int?, EventDispatcher) -> TimedOTPInputViewModel
}

// MARK: Preview helpers

public extension CreateDraftCollateralLoanApplicationFactory {
    
    static let preview = Self(
        makeImageViewWithMD5Hash: { _ in .preview },
        makeImageViewWithURL: { _ in .preview }
//        makeOTPViewModel: { _,_ in .preview }
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
