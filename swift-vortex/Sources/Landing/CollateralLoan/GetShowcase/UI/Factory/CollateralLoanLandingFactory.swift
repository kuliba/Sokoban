//
//  CollateralLoanLandingFactory.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import Combine
import OTPInputComponent
import SwiftUI
import UIPrimitives

public struct CollateralLoanLandingFactory {
    
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
 
public extension CollateralLoanLandingFactory {

    typealias IconView = UIPrimitives.AsyncImage
    typealias MakeImageViewWithMD5Hash = (String) -> IconView
    typealias MakeImageViewWithURL = (String) -> IconView
    typealias FormatCurrency = (UInt) -> String?
}
