//
//  QRFlowButton.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import SwiftUI

struct QRFlowButton<QRFlowButtonLabel: View>: View {
    
    let label: () -> QRFlowButtonLabel
    
    var body: some View {
        
        Button(action: { print("QR") }, label: label)
    }
}

struct QRFlowButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            qrFlowButton()
                .toolbar(content: qrFlowButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private static func qrFlowButton(
    ) -> some View {
        
        QRFlowButton {
            
            Label("Open QR Scanner", systemImage: "qrcode")
        }
    }
}
