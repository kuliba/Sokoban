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
                
                switch qrFailure.qrCode {
                case .none:
                    Group {
                        
                        Button("TBD: Add Company") {
                            
                            // qrFailure.select(.search)
                        }
                        
                        Button("Pay with raw details - INN is missing or URL can't be handled") {
                            
                            qrFailure.select(.payWithDetails(nil))
                        }
                    }
                    
                case let .some(qrCode):
                    
                    Group {
                        
                        Button("Search provider") {
                            
                            qrFailure.select(.search(qrCode))
                        }
                        
                        Button("Pay with details with QR Code") {
                            
                            qrFailure.select(.payWithDetails(qrCode))
                        }
                    }
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
            qrFailure: .init(with: .init(value: UUID().uuidString))
        )
    }
}
