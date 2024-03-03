//
//  PrePaymentMockView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI

struct PrePaymentMockView: View {
    
    @State private var text = ""
    
    var body: some View {
        
        TextField("Text", text: $text)
    }
}

struct PrePaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PrePaymentMockView()
    }
}
