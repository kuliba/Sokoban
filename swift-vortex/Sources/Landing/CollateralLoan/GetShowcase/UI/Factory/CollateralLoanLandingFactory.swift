//
//  CollateralLoanLandingFactory.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import CollateralLoanLandingGetConsentsBackend
import Combine
import OTPInputComponent
import PDFKit
import RemoteServices
import SwiftUI
import UIPrimitives

public struct CollateralLoanLandingFactory {
    
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
 
public extension CollateralLoanLandingFactory {

    typealias Payload = RemoteServices.RequestFactory.GetConsentsPayload
    typealias IconView = UIPrimitives.AsyncImage
    typealias MakeImageViewWithMD5Hash = (String) -> IconView
    typealias MakeImageViewWithURL = (String) -> IconView
    typealias GetPDFDocumentCompletion = (PDFDocument?) -> Void
    typealias GetPDFDocument = (Payload, @escaping GetPDFDocumentCompletion) -> Void
    typealias FormatCurrency = (UInt) -> String?
}

// MARK: Preview helpers

public extension CollateralLoanLandingFactory {
    
//    static var preview: CollateralLoanLandingFactory {
//      
//        .init (
//            makeImageViewWithMD5Hash: { _ in .preview },
//            makeImageViewWithURL: { _ in .preview },
//            getPDFDocument: { _,_ in },
//            formatCurrency: { _ in "" },
//            makeDetailsViewModel: { _,_ in }
//        )
//    }
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
