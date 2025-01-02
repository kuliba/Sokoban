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
    
    private let config: Config
    
    public init(
            makeImageView: @escaping MakeImageView,
            config: Config = .default
        ) {
            self.makeImageView = makeImageView
            self.config = config
        }
    
    public typealias MakeImageView = (String) -> UIPrimitives.AsyncImage
    public typealias Config = CreateDraftCollateralLoanApplicationConfig
}

extension CreateDraftCollateralLoanApplicationFactory {
    
    static let preview = Self(
        makeImageView: { _ in .init(
            image: .iconPlaceholder,
            publisher: Just(.iconPlaceholder).eraseToAnyPublisher()
        )}
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
