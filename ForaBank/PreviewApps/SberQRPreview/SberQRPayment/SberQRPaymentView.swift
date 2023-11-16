//
//  SberQRPaymentView.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct SberQRPaymentView: View {
    
    let url: URL
    
    var body: some View {
        
        Text("SberQRPayment for \(url.absoluteString)")
    }
}

struct SberQRPaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
    
        SberQRPaymentView(url: .init(string: "http://any-url")!)
    }
}
