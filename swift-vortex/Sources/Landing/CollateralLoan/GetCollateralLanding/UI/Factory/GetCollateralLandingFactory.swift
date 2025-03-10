//
//  GetCollateralLandingFactory.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetConsentsBackend
import Combine
import PDFKit
import RemoteServices
import SwiftUI
import UIPrimitives

public struct GetCollateralLandingFactory {

    public let makeImageViewWithMD5Hash: MakeImageViewWithMD5Hash
    public let makeImageViewWithURL: MakeImageViewWithURL
    public let formatCurrency: FormatCurrency
    
    public init(
        makeImageViewWithMD5Hash: @escaping MakeImageViewWithMD5Hash,
        makeImageViewWithURL: @escaping MakeImageViewWithURL,
        formatCurrency: @escaping FormatCurrency
    ) {
        self.makeImageViewWithMD5Hash = makeImageViewWithMD5Hash
        self.makeImageViewWithURL = makeImageViewWithURL
        self.formatCurrency = formatCurrency
    }
}

public extension GetCollateralLandingFactory {
        
    typealias IconView = UIPrimitives.AsyncImage
    typealias MakeImageViewWithMD5Hash = (String) -> IconView
    typealias MakeImageViewWithURL = (String) -> IconView
    typealias FormatCurrency = (UInt) -> String?
}

// MARK: Preview helpers

public extension GetCollateralLandingFactory {
    
    static let preview = Self(
        makeImageViewWithMD5Hash: { _ in .preview },
        makeImageViewWithURL: { _ in .preview },
        formatCurrency: { _ in "" }
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
