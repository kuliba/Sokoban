//
//  TextFieldMockWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.04.2024.
//

import SwiftUI

struct TextFieldMockWrapperView: View {
    
    let onChange: (String) -> Void
    
    private let viewModel: TextFieldMockViewModel
    
    init(
        initial: String,
        onChange: @escaping (String) -> Void
    ) {
        self.onChange = onChange
        self.viewModel = .init(text: initial)
    }
    
    var body: some View {
        
        TextFieldMockStateWrapperView(viewModel: viewModel)
            .onChange(of: viewModel.text, perform: onChange)
    }
}

struct TextFieldMockView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TextFieldMockWrapperView(initial: "abc", onChange: { _ in })
    }
}
