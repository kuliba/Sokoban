//
//  ChevronView.swift
//
//
//  Created by Valentin Ozerov on 28.01.2025.
//

import SwiftUI

struct ChevronView: View {
    
    let state: Bool
    let config: ChevronViewConfig
    
    var body: some View {
        
        config.image
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(state ? -180 : 0))
            .frame(width: config.size, height: config.size)
            .foregroundColor(config.color)
    }
    
    typealias ChevronViewConfig = CreateDraftCollateralLoanApplicationConfig.ChevronViewConfig
}
