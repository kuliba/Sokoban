//
//  CollateralLoanLandingShowCaseProductImageView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import SwiftUI

struct CollateralLoanLandingShowCaseProductImageView: View {
    
    let url: String
    let config: Config

    var body: some View {

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

extension CollateralLoanLandingShowCaseProductImageView {
    
    typealias Config = CollateralLoanLandingShowCaseViewConfig
}
