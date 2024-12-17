//
//  ChevronView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SwiftUI

struct ChevronView: View {
    
    let state: Bool
    let config: ChevronViewConfig
    
    var body: some View {
        
        config.image
            .resizable()
            .rotationEffect(.degrees(state ? -180 : 0))
            .frame(width: config.size, height: config.size)
            .foregroundColor(config.color)
    }
}
