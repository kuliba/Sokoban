//
//  TextFieldMockViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.04.2024.
//

import Foundation

final class TextFieldMockViewModel: ObservableObject {
    
    @Published private(set) var text: String
    
    init(text: String) {
        
        self.text = text
    }
}

extension TextFieldMockViewModel {
    
    func edit(_ text: String) {
        
        self.text = text
    }
}
