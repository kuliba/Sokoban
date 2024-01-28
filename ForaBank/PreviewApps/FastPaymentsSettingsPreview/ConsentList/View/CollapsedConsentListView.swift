//
//  CollapsedConsentListView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 28.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct CollapsedConsentListView<Icon: View, ExpandButton: View>: View {
    
    let collapsed: ConsentListState.UIState.Collapsed
    let icon: () -> Icon
    let expandButton: () -> ExpandButton
    
    var body: some View {
        
        HStack(alignment: .top) {
            
            icon()
            
            VStack(alignment: .leading, spacing:6) {
                
                expandButton()
                
                if !collapsed.bankNames.isEmpty {
                    
                    Text(collapsed.bankNames.joined(separator: ", "))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

//struct CollapsedConsentListView_Preview: PreviewProvider {
//
//    static var previews: some View {
//        
//        CollapsedConsentListView()
//    }
//}
