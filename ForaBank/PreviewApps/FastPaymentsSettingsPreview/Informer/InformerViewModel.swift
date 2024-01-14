//
//  InformerViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import Foundation

final class InformerViewModel: ObservableObject {
    
    @Published private(set) var informer: Informer?
    
    init(informer: Informer? = nil) {
        
        self.informer = informer
    }
}

extension InformerViewModel {
    
    func set(text: String) {
        
        self.informer = .init(text: text)
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2,
            execute: { [weak self] in self?.informer = nil }
        )
    }
}
