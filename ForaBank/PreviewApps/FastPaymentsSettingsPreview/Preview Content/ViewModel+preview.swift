//
//  ViewModel+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension ViewModel {
    
    static func preview(
        route: Route = .init()
    ) -> ViewModel {
        
        let reducer = FastPaymentsSettingsReducer.preview
        
        return .init(
            route: route,
            factory: .init(
                makeFastPaymentsSettingsViewModel: {
                    .init(
                        reduce: reducer.reduce(_:_:_:)
                    )
                }
            )
        )
    }
}
