//
//  TextPickerView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.11.2023.
//

import SwiftUI

struct TextPickerView: View {
    
    let commit: (String) -> Void
    
    private let texts = (1..<5).map { "Text \($0)" }
    
    var body: some View {

        List {

            ForEach(texts, id: \.self) { text in
                
                Button(text) { commit(text) }
            }
        }
    }
}

struct TextPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TextPickerView { _ in }
    }
}
