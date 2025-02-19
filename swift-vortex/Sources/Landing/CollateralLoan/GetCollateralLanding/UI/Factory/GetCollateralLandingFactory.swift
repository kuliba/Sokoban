//
//  GetCollateralLandingFactory.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetShowcaseUI
import Combine
import PDFKit
import SwiftUI
import UIPrimitives

public struct GetCollateralLandingFactory {

    public let config: GetCollateralLandingConfig
    public let makeImageViewWithMD5Hash: MakeImageViewWithMD5Hash
    public let makeImageViewWithURL: MakeImageViewWithURL
    public let getPDFDocument: GetPDFDocument
    
    public init(
        config: GetCollateralLandingConfig = .default,
        makeImageViewWithMD5Hash: @escaping MakeImageViewWithMD5Hash,
        makeImageViewWithURL: @escaping MakeImageViewWithURL,
        getPDFDocument: @escaping GetPDFDocument
    ) {
        self.config = config
        self.makeImageViewWithMD5Hash = makeImageViewWithMD5Hash
        self.makeImageViewWithURL = makeImageViewWithURL
        self.getPDFDocument = getPDFDocument
    }
}

public extension GetCollateralLandingFactory {
        
    typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    typealias MakeImageViewWithMD5Hash = ShowcaseFactory.MakeImageViewWithMD5Hash
    typealias MakeImageViewWithURL = ShowcaseFactory.MakeImageViewWithURL
    typealias GetPDFDocument = CreateDraftCollateralLoanApplicationFactory.GetPDFDocument
}

// MARK: Preview helpers

public extension GetCollateralLandingFactory {
    
    static let preview = Self(
        makeImageViewWithMD5Hash: { _ in .preview },
        makeImageViewWithURL: { _ in .preview },
        getPDFDocument: { _,_ in }
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
