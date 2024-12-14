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
            
            ZStack(alignment: .topTrailing) {
                
                Button {
                    event(.select(.close))
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .foregroundColor(.secondary.opacity(0.5))
                .padding()
                
                Button("Next") { event(.select(.next)) }
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
