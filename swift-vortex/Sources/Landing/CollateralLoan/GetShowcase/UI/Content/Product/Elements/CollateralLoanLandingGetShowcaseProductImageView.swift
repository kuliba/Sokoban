//
//  CollateralLoanLandingGetShowcaseProductImageView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

struct CollateralLoanLandingGetShowcaseProductImageView: View {
    
    let url: String
    let config: Config
    let makeImageViewWithURL: Factory.MakeImageViewWithURL
    
    var body: some View {

        ZStack {
            
            makeImageViewWithURL(url)
                .scaledToFill()
                .frame(height: config.imageView.height)
                .cornerRadius(config.imageView.сornerRadius)
        }
        .padding(.top, config.paddings.top)
        .padding(.leading, config.paddings.outer.leading)
        .padding(.trailing, config.paddings.outer.trailing)
    }
}

extension CollateralLoanLandingGetShowcaseProductImageView {
    
    typealias Md5hash = String
    typealias Config = CollateralLoanLandingGetShowcaseViewConfig
    typealias Factory = CollateralLoanLandingFactory
}
