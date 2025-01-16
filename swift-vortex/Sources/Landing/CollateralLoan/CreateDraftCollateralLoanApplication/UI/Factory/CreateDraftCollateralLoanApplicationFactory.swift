//
//  CreateDraftCollateralLoanApplicationFactory.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import Combine
import SwiftUI
import UIPrimitives

public struct CreateDraftCollateralLoanApplicationFactory {
    
    let makeImageView: MakeImageView
    let makeImageViewWithMD5hash: MakeImageViewWithMD5hash
    let makeImageViewWithURL: MakeImageViewWithURL
    
    private let config: Config
    
    public init(
        makeImageView: @escaping MakeImageView,
        makeImageViewWithMD5hash: @escaping MakeImageViewWithMD5hash,
        makeImageViewWithURL: @escaping MakeImageViewWithURL,
        config: Config
    ) {
        self.makeImageView = makeImageView
        self.makeImageViewWithMD5hash = makeImageViewWithMD5hash
        self.makeImageViewWithURL = makeImageViewWithURL
        self.config = config
    }
    
    public typealias Config = CreateDraftCollateralLoanApplicationConfig
    public typealias MakeImageView = () -> UIPrimitives.AsyncImage
    public typealias MakeImageViewWithMD5hash = (String) -> UIPrimitives.AsyncImage
    public typealias MakeImageViewWithURL = (String) -> UIPrimitives.AsyncImage
}

extension CreateDraftCollateralLoanApplicationFactory {
    
    static let preview = Self(
        makeImageView: {
            .init(
                image: .iconPlaceholder,
                publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
            )},
        makeImageViewWithMD5hash: { _ in
                .init(
                    image: .iconPlaceholder,
                    publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
                )},
        makeImageViewWithURL: { _ in
            
                .init(
                    image: .iconPlaceholder,
                    publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
                )
        },
        config: .preview
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
