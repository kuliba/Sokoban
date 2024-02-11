//
//  PreviewClearButton.swift
//
//
//  Created by Igor Malyarov on 10.02.2024.
//

import SwiftUI

struct PreviewClearButton: View {
    
    var body: some View {
        
        Image(systemName: "xmark")
            .resizable()
            .imageScale(.small)
            .frame(width: 12, height: 12)
            .foregroundColor(.gray)
    }
}

struct PreviewClearButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PreviewClearButton()
    }
}
