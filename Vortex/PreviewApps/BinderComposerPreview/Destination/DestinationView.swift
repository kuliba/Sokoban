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
            
            Button("Next") { event(.select(.next)) }
                .font(.headline.bold())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    
                    Button {
                        event(.select(.close))
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                    }
                    .foregroundColor(.secondary.opacity(0.7))
                }
        }
    }
}
