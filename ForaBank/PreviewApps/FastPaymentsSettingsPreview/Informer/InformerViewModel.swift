//
//  InformerViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import Foundation

final class InformerViewModel: ObservableObject {
    
    @Published private(set) var informer: Informer?

    private let delay: TimeInterval
    
    init(
        informer: Informer? = nil,
        delay: TimeInterval = 2
    ) {
        self.informer = informer
        self.delay = delay
    }
}

extension InformerViewModel {
    
    func set(text: String?) {
        
        self.informer = text.map(Informer.init(text:))
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay,
            execute: { [weak self] in self?.informer = nil }
        )
    }
}
