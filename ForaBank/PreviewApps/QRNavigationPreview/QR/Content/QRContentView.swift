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
                    
                    Button("SberQR") {
                        
                        model.emit(.sberQR(.init(string: "sberQR")!))
                    }
                    
                    Button("missing INN") {
                        
                        model.emit(.mapped(.missingINN(.init(value: "QRCOde"))))
                    }
                    .foregroundColor(.red)
                    
                    Button("Mixed Operators") {
                        
                        model.emit(.mapped(.mixed(.init(
                            operators: .init(
                                .operator(.init()),
                                .provider(.init())
                            ),
                            qrCode: .init(value: UUID().uuidString),
                            qrMapping: .init()
                        ))))
                    }
                    
                    Button("Multiple Operators") {
                        
                        model.emit(.mapped(.multiple(.init(
                            operators: .init(.init(), .init()),
                            qrCode: .init(value: UUID().uuidString),
                            qrMapping: .init()
                        ))))
                    }
                    
                    Button("none") {
                        
                        model.emit(.mapped(.none(.init(value: .init(UUID().uuidString.prefix(4))))))
                    }
                    .foregroundColor(.red)
                    
                    Button("provider") {
                        
                        model.emit(.mapped(.provider(.init(
                            provider: .init(),
                            qrCode: .init(value: UUID().uuidString),
                            qrMapping: .init()
                        ))))
                    }
                    
                    Button("single operator") {
                        
                        model.emit(.mapped(.single(.init(
                            operator: .init(),
                            qrCode: .init(value: UUID().uuidString),
                            qrMapping: .init()
                        ))))
                    }
                    
                    Button("source") {
                        
                        model.emit(.mapped(.source(.init())))
                    }
                    
                    Button("url") {
                        
                        model.emit(.url(.init(string: "any-url")!))
                    }
                    
                    Button("unknown") {
                        
                        model.emit(.unknown)
                    }
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
