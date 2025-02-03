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
    
    public let makeImageViewWithMD5hash: MakeImageViewWithMD5hash
    public let makeImageViewWithURL: MakeImageViewWithURL
    
    public init(
        makeImageViewWithMD5hash: @escaping MakeImageViewWithMD5hash,
        makeImageViewWithURL: @escaping MakeImageViewWithURL
    ) {
        self.makeImageViewWithMD5hash = makeImageViewWithMD5hash
        self.makeImageViewWithURL = makeImageViewWithURL
    }
    
    public typealias MakeImageViewWithMD5hash = (String) -> UIPrimitives.AsyncImage
    public typealias MakeImageViewWithURL = (String) -> UIPrimitives.AsyncImage
}

extension CreateDraftCollateralLoanApplicationFactory {
    
    static let preview = Self(
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
        }
    )
}

extension Image {
    
    static var iconPlaceholder: Image { Image(systemName: "info.circle") }
}
