//
//  QRReaderButton.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct QRReaderButton: View {
    
    let action: () -> Void
    
    var body: some View {
        
        Button(action: action) {
            
            Image(systemName: "qrcode.viewfinder")
                .imageScale(.large)
        }
    }
}

struct QRReaderButton_Previews: PreviewProvider {
    static var previews: some View {
        QRReaderButton {}
    }
}
