//
//  SpinnerView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct SpinnerView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.secondary.opacity(0.3)
            
            ProgressView()
        }
    }
}

#Preview {
    SpinnerView()
}
