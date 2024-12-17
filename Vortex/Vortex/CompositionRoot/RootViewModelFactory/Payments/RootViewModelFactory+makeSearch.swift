//
//  RootViewModelFactory+makeSearch.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.12.2024.
//

import TextFieldModel

extension RootViewModelFactory {
    
    @inlinable
    func makeSearch(
        placeholderText: String
    ) -> RegularFieldViewModel {
        
        let searchReducer = TransformingReducer(
            placeholderText: placeholderText,
            transform: { $0 }
        )
        
        return .init(
            initialState: .placeholder(placeholderText),
            reducer: searchReducer,
            keyboardType: .default
        )
    }
}
