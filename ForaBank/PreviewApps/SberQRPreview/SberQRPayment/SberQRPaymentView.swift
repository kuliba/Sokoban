//
//  SberQRPaymentView.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct SberQRPaymentView: View {
    
    typealias AsyncGet = (URL, @escaping (String?) -> Void) -> Void
    
    let url: URL
    let dismiss: () -> Void
    let asyncGet: AsyncGet
    
    @State private var text: String?
    
    var body: some View {
        
        VStack {
            
            Text("SberQRPayment")
                .font(.largeTitle.bold())
                .padding(.top, 48)
            
            Text("for \(url.absoluteString)")
                .font(.caption)
                .frame(maxHeight: .infinity)
            
            Text(text ?? "n/a")
                .frame(maxHeight: .infinity)
            
            Button {
                asyncGet(url) { text = $0 }
            } label: {
                Text("Get async data")
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
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
            url: .init(string: "https://platiqr.ru/?uuid=3001638371&amount=27.50&trxid=2023072420443097822")!,
            dismiss: {},
            asyncGet: { _, completion in completion("Some text") }
        )
    }
}
