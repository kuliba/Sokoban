//
//  UtilityPaymentOperatorPickerFooterView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

enum UtilityPaymentOperatorPickerFooterEvent {
    
    case addCompany
    case payByInstructions
}

struct UtilityPaymentOperatorPickerFooterView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        if state {
            Button("Add Company") { event(.addCompany) }
        }
        
        Button("Pay by Instructions") { event(.payByInstructions) }
    }
}

extension UtilityPaymentOperatorPickerFooterView {
    
    typealias State = Bool
    typealias Event = UtilityPaymentOperatorPickerFooterEvent
}

//#Preview {
//    UtilityPaymentOperatorPickerFooterView()
//}
