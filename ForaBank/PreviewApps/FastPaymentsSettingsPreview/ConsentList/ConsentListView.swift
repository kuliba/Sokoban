//
//  ConsentListView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct ConsentListView: View {
    
    let state: ConsentListState
    let event: (ConsentListEvent) -> Void
    
    var body: some View {
        
        Group {
            
            switch state {
            case .collapsed:
                Text("ConsentListView: collapsed")
                
            case .expanded:
                Text("ConsentListView: expanded")
                
            case .collapsedError:
                Text("ConsentListView: collapsedError")
                
            case .expandedError:
                Text("ConsentListView: expandedError")
            }
        }
        .animation(.easeInOut, value: state)
    }
}

struct ConsentListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        consentListView(.collapsed)
        consentListView(.expanded)
        consentListView(.collapsedError)
        consentListView(.expandedError)
    }
    
    private static func consentListView(
        _ state: ConsentListState
    ) -> some View {
        
        ConsentListView(
            state: state,
            event: { _ in }
        )
    }
}
