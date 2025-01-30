//
//  CollateralLoanLandingGetShowcaseViewFactory.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import Combine
import OTPInputComponent
import SwiftUI
import UIPrimitives

public struct CollateralLoanLandingGetShowcaseViewFactory {
    
    public let config: CollateralLoanLandingGetShowcaseViewConfig
    public let makeImageViewByMD5Hash: MakeImageViewByMD5Hash
    public let makeImageViewByURL: MakeImageViewByURL
    public let makeOTPView: MakeOTPView
    
    public init(
        config: CollateralLoanLandingGetShowcaseViewConfig = .base,
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
 
public extension CollateralLoanLandingGetShowcaseViewFactory {

    typealias IconView = UIPrimitives.AsyncImage
    typealias MakeImageViewByMD5Hash = (String) -> IconView
    typealias MakeImageViewByURL = (String) -> IconView
    typealias OTPViewModel = TimedOTPInputViewModel
    typealias OTPView = TimedOTPInputWrapperView<IconView, OTPWarningView>
    typealias MakeOTPView = (OTPViewModel) -> OTPView
}

// MARK: Preview helpers

extension CollateralLoanLandingGetShowcaseViewFactory {
    
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
    
    static let preview = UIPrimitives.AsyncImage(
        image: .iconPlaceholder,
        publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}

public extension OTPWarningView {
    
    static let preview = Self(
        text: nil,
        config: .preview
    )
}

public extension CollateralLoanLandingGetShowcaseViewConfig.OTPWarningViewConfig {
    
    static let preview = Self(
        text: .preview
    )
}

public extension TimedOTPInputWrapperView.ViewModel {
    
    static var preview = OTPView.ViewModel(
        initialState: .preview,
        reduce: { _,_ in (.preview, nil) },
        handleEffect: { _,_ in }
    )
    
    typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
    typealias OTPView = Factory.OTPView
    typealias IconView = Factory.IconView
}

public extension TimedOTPInputWrapperView.Config {
    
    static var preview = OTPView.Config(
        otp: .preview,
        resend: .preview,
        timer: .preview,
        title: .preview
    )
    
    typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
    typealias OTPView = Factory.OTPView
    typealias IconView = Factory.IconView
}

extension TextConfig {
    
    static var preview = Self(
        textFont: Font.system(size: 14),
        textColor: .primary
    )
}

extension TimedOTPInputWrapperView.Config.ResendConfig {
    
    static var preview = Self(
        text: "Отправить снова",
        backgroundColor: .yellow,
        config: .preview
    )
}

extension TimedOTPInputWrapperView.Config.TimerConfig {
    
    static var preview = Self(
        backgroundColor: .blue,
        config: .preview
    )
}

extension TitleConfig {
    
    static var preview = Self(
        text: "",
        config: .preview
    )
}

extension OTPInputViewModel {
    
    static let preview = OTPInputViewModel(
        initialState: .preview,
        reduce: { _,_ in (.preview, nil) },
        handleEffect: { _,_ in}
    )
}

extension OTPInputState {
    
    static let preview = Self(
        phoneNumber: .init("123"),
        status: .validOTP
    )
}
