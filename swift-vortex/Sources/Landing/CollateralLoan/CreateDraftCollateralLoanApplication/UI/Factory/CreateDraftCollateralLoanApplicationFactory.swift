//
//  CreateDraftCollateralLoanApplicationFactory.swift
//
//
//  Created by Valentin Ozerov on 30.12.2024.
//

import CollateralLoanLandingGetShowcaseUI
import Combine
import OTPInputComponent
import PDFKit
import SwiftUI
import UIPrimitives

public struct CreateDraftCollateralLoanApplicationFactory {
    
    public let makeImageViewWithMD5Hash: MakeImageViewWithMD5Hash
    public let makeImageViewWithURL: MakeImageViewWithURL
    public let getPDFDocument: GetPDFDocument
    public let formatCurrency: FormatCurrency
    
    public init(
        makeImageViewWithMD5Hash: @escaping MakeImageViewWithMD5Hash,
        makeImageViewWithURL: @escaping MakeImageViewWithURL,
        getPDFDocument: @escaping GetPDFDocument,
        formatCurrency: @escaping FormatCurrency
    ) {
        self.makeImageViewWithMD5Hash = makeImageViewWithMD5Hash
        self.makeImageViewWithURL = makeImageViewWithURL
        self.getPDFDocument = getPDFDocument
        self.formatCurrency = formatCurrency
    }
}

public extension CreateDraftCollateralLoanApplicationFactory {
    
    func makeCreateDraftCollateralLoanApplicationFactory() -> CreateDraftCollateralLoanApplicationFactory {
        
        .init(
            makeImageViewWithMD5Hash: makeImageViewWithMD5Hash,
            makeImageViewWithURL: makeImageViewWithURL,
            getPDFDocument: getPDFDocument,
            formatCurrency: formatCurrency
        )
    }
}

public extension CreateDraftCollateralLoanApplicationFactory {
    
    typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    typealias MakeImageViewWithMD5Hash = ShowcaseFactory.MakeImageViewWithMD5Hash
    typealias MakeImageViewWithURL = ShowcaseFactory.MakeImageViewWithURL
    typealias GetPDFDocument = ShowcaseFactory.GetPDFDocument
    typealias FormatCurrency = (UInt) -> String?
}

// MARK: Preview helpers

public extension CreateDraftCollateralLoanApplicationFactory {
    
    static let preview = Self(
        makeImageViewWithMD5Hash: { _ in .preview },
        makeImageViewWithURL: { _ in .preview },
        getPDFDocument: { _,_ in },
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

extension TimedOTPInputViewModel {
    
    static let preview = TimedOTPInputViewModel(
        otpText: "44",
        timerDuration: 60,
        otpLength: 4,
        resend: {}
    )
}
