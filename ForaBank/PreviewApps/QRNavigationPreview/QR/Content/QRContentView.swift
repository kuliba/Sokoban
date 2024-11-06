//
//  QRContentView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import SwiftUI

struct QRContentView: View {
    
    let model: QRModel
    
    var body: some View {
        
        VStack {
            
            Text("Select scan result")
                .foregroundColor(.secondary)
                .padding(.vertical)
            
            Button("c2b Subscribe") {
                
                model.emit(.c2bSubscribeURL(.init(string: "c2bSubscribeURL")!))
            }
        }
        .navigationTitle("QR Scanner")
    }
}
