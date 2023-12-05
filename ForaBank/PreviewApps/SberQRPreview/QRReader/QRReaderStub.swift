//
//  QRReaderStub.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct QRReaderStub: View {
    
    let commit: (QRParsingResult) -> Void
    
    private let stubbedURL = URL(string: "https://platiqr.ru/?uuid=3001638371&amount=27.50&trxid=2023072420443097822")!
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 32) {
                
                VStack {
                    
                    Text(stubbedURL.absoluteString)
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Button {
                        commit(.sberQR(stubbedURL))
                    } label: {
                        Label("Use link above", systemImage: "qrcode")
                            .foregroundColor(.green)
                    }
                }
                
                Button(role: .destructive) {
                    commit(.error("QR Parsing Error"))
                } label: {
                    Label("QR Parsing Error", systemImage: "exclamationmark.octagon")
                }
            }
            .buttonStyle(.bordered)
            .padding()
            .navigationTitle("QR Reader Stub")
        }
    }
}

struct QRReaderStub_Previews: PreviewProvider {
    
    static var previews: some View {
        
        QRReaderStub_Demo()
    }
    
    struct QRReaderStub_Demo: View {
        
        @State private var message: String?
        
        var body: some View {
            
            QRReaderStub { result in
                
                switch result {
                case let .sberQR(url):
                    message = url.absoluteString
                    
                case let .error(string):
                    message = string
                }
            }
            .alert(
                "QR Reader Stub Result",
                isPresented: .init(
                    get: { message != nil },
                    set: { if !$0 { message = nil }}
                ),
                actions: { Button("OK") { message = nil } },
                message: { Text(message ?? "n/a") }
            )
        }
    }
}
