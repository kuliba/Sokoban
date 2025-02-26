//
//  MakeSearchByUINContentView_Previews.swift
//  Vortex
//
//  Created by Igor Malyarov on 26.02.2025.
//

import InputComponent
import SwiftUI

// MARK: - Previews

struct MakeSearchByUINContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        makeSearchByUINContentView(.init(textField: .editing(.init("abc", cursorAt: 1)), message: .warning("warning")))
        
        VStack {
            
            makeSearchByUINContentView(.init(textField: .placeholder("Enter value")))
            makeSearchByUINContentView(.init(textField: .placeholder("Enter value"), message: .hint("hint")))
            makeSearchByUINContentView(.init(textField: .placeholder("Enter value"), message: .warning("warning")))
        }
        .previewDisplayName("placeholder")
        
        VStack {
            makeSearchByUINContentView(.init(textField: .noFocus("Value")))
            makeSearchByUINContentView(.init(textField: .noFocus("Value"), message: .hint("hint")))
            makeSearchByUINContentView(.init(textField: .noFocus("Value"), message: .warning("warning")))
        }
        .previewDisplayName("noFocus")
        
        VStack {
            
            makeSearchByUINContentView(.init(textField: .editing(.init("a", cursorAt: 1))))
            makeSearchByUINContentView(.init(textField: .editing(.init("a", cursorAt: 1)), message: .hint("hint")))
            makeSearchByUINContentView(.init(textField: .editing(.init("a", cursorAt: 1)), message: .warning("warning")))
        }
        .previewDisplayName("editing")
    }
    
    static func makeSearchByUINContentView(
        _ state: TextInputState
    ) -> some View {
        
        ViewComponents.preview.makeSearchByUINContentView(state, { print($0) }, {})
    }
}
