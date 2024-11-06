//
//  PaymentsView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import SwiftUI

struct PaymentsView: View {
    
    let model: Payments
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Text("Payments View for **\(model.url.relativeString)**")
                .foregroundColor(.secondary)
            
            Button("Close", action: model.close)
        }
        .navigationTitle("Payments")
    }
}
