//
//  CollateralLoanLandingShowCaseProductImageView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingShowCaseProductImageView: View {
    
    public let url: String
    public let config: Config

    public init(url: String, config: Config) {
        self.url = url
        self.config = config
    }
    
    public var body: some View {

        ZStack {
            
            RoundedRectangle(cornerRadius: config.imageView.сornerRadius)
                .fill(.gray)
                .frame(height: config.imageView.height)
            Text("Image")
                .font(.system(size: 32).bold())
                .foregroundColor(.white)
        }
        .padding(.top, config.paddings.top)
        .padding(.leading, config.paddings.outer.leading)
        .padding(.trailing, config.paddings.outer.trailing)
    }
}

public extension CollateralLoanLandingShowCaseProductImageView {
    
    typealias Config = CollateralLoanLandingShowCaseViewConfig
}
