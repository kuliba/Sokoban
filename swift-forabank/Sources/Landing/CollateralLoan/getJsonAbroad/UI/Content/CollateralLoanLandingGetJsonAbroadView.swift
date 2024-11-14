//
//  CollateralLoanLandingGetJsonAbroadView.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetJsonAbroadView: View {
    
    private let content: Content
    
    private let factory: Factory
    
    public init(
        content: Content,
        factory: Factory
    ) {
        self.content = content
        self.factory = factory
    }
    
    public var body: some View {
        
        Text("CollateralLoanLandingGetJsonAbroadView")
    }
}

public extension CollateralLoanLandingGetJsonAbroadView {
    
    typealias Content = CollateralLoanLandingGetJsonAbroadContent
    typealias Factory = CollateralLoanLandingGetJsonAbroadViewFactory
}

// MARK: - Previews

extension GetJsonAbroadData {
    
//    static let carStub = Self()
}

extension GetJsonAbroadData {
    
//    static let realEstateStub = Self()
}
