//
//  HeaderView.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct HeaderView: View {
    
    let header: SberQRConfirmPaymentState.Header
    
    var body: some View {
        Text("HeaderView")
    }
}

// MARK: - Previews

struct HeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        HeaderView(header: .preview)
    }
}
