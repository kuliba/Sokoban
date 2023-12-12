//
//  InfoView.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct InfoView: View {
    
    let info: SberQRConfirmPaymentState.Info
    
    var body: some View {
        
        Text(String(describing: info))
    }
}

// MARK: - Previews

struct InfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            InfoView(info: .amount)
            InfoView(info: .brandName)
            InfoView(info: .recipientBank)
        }
    }
}
