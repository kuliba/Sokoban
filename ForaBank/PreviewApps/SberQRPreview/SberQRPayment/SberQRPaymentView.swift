//
//  SberQRPaymentView.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct SberQRPaymentView: View {
    
    let url: URL
    let dismiss: () -> Void
    
    var body: some View {
        
        VStack {
            Text("SberQRPayment")
                .font(.largeTitle.bold())
            
            Text("for \(url.absoluteString)")
                .font(.caption)
                .frame(maxHeight: .infinity)
        }
        .overlay(alignment: .topLeading, content: backButton)
        .padding()
    }
    
    private func backButton() -> some View {
        
        Button(action: dismiss) {
            
            Image(systemName: "chevron.left")
        }
    }
}

struct SberQRPaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        SberQRPaymentView(
            url: .init(string: "http://any-url")!,
            dismiss: {}
        )
    }
}
