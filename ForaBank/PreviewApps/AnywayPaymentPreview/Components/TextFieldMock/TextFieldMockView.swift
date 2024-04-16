//
//  TextFieldMockView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.04.2024.
//

import SwiftUI

struct TextFieldMockView: View {
    
    let initial: String
    let onChange: (String) -> Void
    
    private let viewModel: TextFieldMockViewModel
    
    init(
        initial: String,
        onChange: @escaping (String) -> Void
    ) {
        self.initial = initial
        self.onChange = onChange
        self.viewModel = .init(text: initial)
    }
    
    var body: some View {
        
        TextFieldMockWrapperView(viewModel: viewModel)
            .onChange(of: viewModel.text, perform: onChange)
    }
}

struct TextFieldMockView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TextFieldMockView(initial: "abc", onChange: { _ in })
    }
}
