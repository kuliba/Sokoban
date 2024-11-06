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
        
        List {
            
            Section("Select scan result") {
                
                Group {
                    
                    Button("c2b Subscribe") {
                        
                        model.emit(.c2bSubscribeURL(.init(string: "c2bSubscribeURL")!))
                    }
                    
                    Button("c2b") {
                        
                        model.emit(.c2bURL(.init(string: "c2bURL")!))
                    }
                    
                    Button("failure") {
                        
                        model.emit(.failure(.init(value: "QRCOde")))
                    }
                    .foregroundColor(.red)
                }
                .foregroundColor(.blue)
            }
        }
        .listStyle(.inset)
        .navigationTitle("QR Scanner")
    }
}

#Preview {
    
    QRContentView(model: .init())
}
