//
//  OperatorsView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct OperatorsView<Icon>: View {
    
    let state: State
    let event: (Operator) -> Void
    let config: Config
    
    var body: some View {
        
        List {
            
            ForEach(state, content: operatorView)
        }
    }
    
    private func operatorView(
        `operator`: Operator
    ) -> some View {
        
        Button(String(describing: `operator`).prefix(32)) {
            
            event(`operator`)
        }
    }
}

extension OperatorsView {
    
    typealias Operator = UtilityPaymentOperatorPickerState<Icon>.Operator
    typealias State = [Operator]
    typealias Config = OperatorsPickerConfig
}

struct OperatorsPickerConfig {
    
}

//#Preview {
//    OperatorsView()
//}
