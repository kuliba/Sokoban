//
//  InfoView.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

import SwiftUI

struct InfoView<Icon, ImageView: View>: View {
    
    let state: State
    let config: InfoViewConfig
    let imageView: () -> ImageView
    
    var body: some View {
        
        // with config
        HStack {
            
            imageView()
                .frame(width: 32, height: 32)
            
            VStack {
                
                Text(state.title)
                Text(state.subtitle)
            }
        }
    }
}

extension InfoView {
    
    typealias State = Info<Icon>
}

struct InfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InfoView(
            state: .preview,
            config: .preview,
            imageView: { Text("Icon view") }
        )
    }
}

extension Info where Icon == String {
    
    static var preview: Self {
        
        .init(icon: "icon", title: "title", subtitle: "subtitle")
    }
}

extension InfoViewConfig {
    
    static let preview: Self = .init()
}
