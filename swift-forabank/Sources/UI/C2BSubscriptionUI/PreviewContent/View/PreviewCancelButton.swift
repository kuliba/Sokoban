//
//  PreviewCancelButton.swift
//
//
//  Created by Igor Malyarov on 10.02.2024.
//

import SwiftUI

struct PreviewCancelButton: View {
    
    let cancel: () -> Void
    
    var body: some View {
        
        Button(action: cancel) {
            Text("cancel")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
    }
}


struct PreviewCancelButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PreviewCancelButton {}
    }
}
