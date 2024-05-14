//
//  UtilityPaymentWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.02.2024.
//

import SwiftUI

struct UtilityPaymentWrapperView: View {
    
    let state: UtilityPaymentState
    let event: (UtilityPaymentEvent) -> Void
    
    var body: some View {
        #warning("replace with `UtilityPaymentView` from module")
        
        Text("TBD: payment for \(String(describing: state))")
    }
}

struct UtilityPaymentWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
               
        UtilityPaymentWrapperView(
            state: .init(),
            event: { _ in }
        )
    }
}
