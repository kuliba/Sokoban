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

    public init(
        config: CollateralLoanLandingGetShowcaseViewConfig = .base,
        makeImageViewByMD5Hash: @escaping MakeImageViewByMD5Hash,
        makeImageViewByURL: @escaping MakeImageViewByURL
    ) {
        self.config = config
        self.makeImageViewByMD5Hash = makeImageViewByMD5Hash
        self.makeImageViewByURL = makeImageViewByURL
    }
 
    typealias IconView = UIPrimitives.AsyncImage
    
    public typealias MakeImageViewByMD5Hash = (String) -> UIPrimitives.AsyncImage
    public typealias MakeImageViewByURL = (String) -> UIPrimitives.AsyncImage
    public typealias OTPView = TimedOTPInputWrapperView<IconView, GetShowcaseOTPWarningView>
}

extension CollateralLoanLandingGetShowcaseViewFactory {
    
    static let preview = Self(
        makeImageViewByMD5Hash: {
            _ in .init(
                image: .iconPlaceholder,
                publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
            )
        },
        makeImageViewByURL: { _ in
                .init(
                    image: .iconPlaceholder,
                    publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
                )}
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
