//
//  DestinationView.swift
//  BinderComposerPreview
//
//  Created by Igor Malyarov on 14.12.2024.
//

import RxViewModel
import SwiftUI

struct DestinationView: View {
    
    @ObservedObject var model: DestinationDomain.Content
    
    var body: some View {
        
        RxWrapperView(model: model) { state, event in
            
            VStack(spacing: 32) {
                
                Button("Close") { event(.select(.close)) }
                Button("Next") { event(.select(.next)) }
            }
        }
    }
}
