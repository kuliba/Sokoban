//
//  OTPView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.04.2024.
//

import SwiftUI

struct OTPView: View {
    
    let state: String
    let event: (String) -> Void
    
    var body: some View {
        
        HStack {
            
            Text("Enter OTP:")
            TextField("OTP here", text: .init(get: { state }, set: event))
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct OTPView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OTPView(state: "", event: { _ in })
            .padding(.horizontal)
    }
}
