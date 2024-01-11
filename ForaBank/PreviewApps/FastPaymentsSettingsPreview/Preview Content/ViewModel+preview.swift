//
//  ViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension ViewModel {
    
    static func preview(route: Route = .init()) -> ViewModel {
        
        .init(route: route, factory: .preview)
    }
}
