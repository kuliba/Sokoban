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
        
        model.source.text
            .foregroundColor(.secondary)
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Payments")
            .navigationBarBackButtonHidden()
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Button(action: model.close) {
                        
                        Image(systemName: "chevron.left")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button(action: model.scanQR) {
                        
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
            }
    }
}

private extension Payments.Source {
    
    var text: Text {
        
        switch self {
        case let .qrCode(qrCode):
            Text("Payments View for QR Code **\(qrCode.value)**")
            
        case let .url(url):
            Text("Payments View for url: **\(url.relativeString)**")
        }
    }
}

#Preview {
    
    NavigationView {
        
        PaymentsView(model: .init(
            qrCode: .init(value: .init(UUID().uuidString.prefix(6)))
        ))
    }
}
