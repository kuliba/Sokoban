//
//  UtilityPrepaymentView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

struct UtilityPrepaymentView: View {
    
    let state: State
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            Text(String(describing: state))
                .padding()
                .navigationTitle("Destination View")
        }
    }
}

extension UtilityPrepaymentView {
    
    typealias State = PaymentFlowState.Destination.UtilityPrepaymentState
}

struct UtilityPrepaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(.preview)
            preview(.empty)
        }
    }
    
    private static func preview(
        _ state: UtilityPrepaymentView.State
    ) -> some View {
        
        UtilityPrepaymentView(state: state)
    }
}
