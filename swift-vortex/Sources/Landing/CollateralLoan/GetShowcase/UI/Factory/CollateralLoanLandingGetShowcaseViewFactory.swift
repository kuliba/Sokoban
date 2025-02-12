//
//  CollateralLoanLandingGetShowcaseViewFactory.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import Combine
import OTPInputComponent
import PDFKit
import SwiftUI
import UIPrimitives

public struct CollateralLoanLandingGetShowcaseViewFactory {
    
    public let config: CollateralLoanLandingGetShowcaseViewConfig
    public let makeImageViewWithMD5Hash: MakeImageViewWithMD5Hash
    public let makeImageViewWithURL: MakeImageViewWithURL
    public let getPDFDocument: GetPDFDocument
    
    public init(
        config: CollateralLoanLandingGetShowcaseViewConfig = .base,
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
 
public extension CollateralLoanLandingGetShowcaseViewFactory {

    typealias IconView = UIPrimitives.AsyncImage
    typealias MakeImageViewWithMD5Hash = (String) -> IconView
    typealias MakeImageViewWithURL = (String) -> IconView
    typealias GetPDFDocumentCompletion = (PDFDocument?) -> Void
    typealias GetPDFDocument = (@escaping GetPDFDocumentCompletion) -> Void
}

// MARK: Preview helpers

extension CollateralLoanLandingGetShowcaseViewFactory {
    
    static let preview = Self(
        makeImageViewWithMD5Hash: { _ in .preview },
        makeImageViewWithURL: { _ in .preview },
        getPDFDocument: { _ in }
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
