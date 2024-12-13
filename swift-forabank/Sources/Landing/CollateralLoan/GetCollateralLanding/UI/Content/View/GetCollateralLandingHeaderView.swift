//
//  GetCollateralLandingHeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

import SwiftUI
import UIPrimitives

struct GetCollateralLandingHeaderView: View {
    
    private let config: Config
    
    init(config: Config) {
        self.config = config
    }
    
    public var body: some View {
        
        Spacer()
            .frame(height: config.header.height)
    }
}

extension GetCollateralLandingHeaderView {
    
    typealias Config = GetCollateralLandingConfig
}
