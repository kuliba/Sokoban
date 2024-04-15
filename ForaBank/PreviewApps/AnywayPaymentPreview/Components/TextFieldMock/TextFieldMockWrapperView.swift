//
//  TextFieldMockWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.04.2024.
//

import SwiftUI

struct TextFieldMockWrapperView: View {
    
    @StateObject var viewModel: TextFieldMockViewModel

    var body: some View {
        
        TextField("", text: .init(
            get: { viewModel.text },
            set: viewModel.edit(_:)
        ))
    }
}

struct TextFieldMockWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
 
        TextFieldMockWrapperView(viewModel: .init(text: "abc"))
    }
}
