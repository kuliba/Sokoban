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
                
                switch qrFailure.details {
                case .none:
                    Group {
                        
                        Button("TBD: Add Company") {
                            
                            // qrFailure.select(.search)
                        }
                        
                        Button("Pay with raw details - url can't be handled") {
                            
                            qrFailure.select(.payWithDetails(nil))
                        }
                    }
                    
                case let .missingINN(qrCode):
                    Group {
                        
                        Button("TBD: Add Company") {
                            
                            // qrFailure.select(.search)
                        }
                        
                        Button("Pay with details without QR Code - INN is missing") {
                            
                            qrFailure.select(.payWithDetails(nil))
                        }
                    }
                    
                case let .qrCode(qrCode):
                    
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
            qrFailure: .init(with: .qrCode(.init(value: UUID().uuidString)))
        )
    }
}
