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
    
    let makeImageViewWithMd5hash: MakeImageViewWithMd5hash
    let makeImageView: MakeImageView
    
    private let config: Config
    
    public init(
            makeImageViewWithMd5hash: @escaping MakeImageViewWithMd5hash,
            makeImageView: @escaping MakeImageView,
            config: Config
        ) {
            self.makeImageViewWithMd5hash = makeImageViewWithMd5hash
            self.makeImageView = makeImageView
            self.config = config
        }
    
    public typealias MakeImageViewWithMd5hash = (String) -> UIPrimitives.AsyncImage
    public typealias MakeImageView = () -> UIPrimitives.AsyncImage
    public typealias Config = CreateDraftCollateralLoanApplicationConfig
}

extension CreateDraftCollateralLoanApplicationFactory {
    
    static let preview = Self(
        makeImageViewWithMd5hash: { _ in .init(
            image: .iconPlaceholder,
            publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
        )},
        makeImageView: {
          
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
