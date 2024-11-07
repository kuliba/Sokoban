//
//  QRFailureView.swift
//  QRNavigationPreviewTests
//
//  Created by Igor Malyarov on 06.11.2024.
//

import SwiftUI

struct QRFailureView: View {
    
    let qrFailure: QRFailure
    
    var body: some View {
        
        List {
            
            Button("Search provider failure") {
                
                qrFailure.select(.search(.init(value: "")))
            }
            .foregroundColor(.red)
            
            Group {
                
                Button("Search provider") {
                    
                    qrFailure.select(.search(qrFailure.qrCode))
                }
                
                Button("Pay with details") {
                    
                    qrFailure.select(.payWithDetails(qrFailure.qrCode))
                }
            }
            .foregroundColor(.blue)
        }
        .listStyle(.inset)
        .navigationTitle("QR Failure")
    }
}

#Preview {
    
    NavigationView {
        
        QRFailureView(
            qrFailure: .init(qrCode: .init(value: UUID().uuidString))
        )
    }
}
