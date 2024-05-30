//
//  SelectorViewFactory+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

extension SelectorViewFactory<String, OptionView, SelectedOptionView> {
    
    static var preview: Self {
        
        return .init(
            createOptionView: { .init(option: .init(key: .init($0), value: .init($0))) },
            createSelectedOptionView: { .init(option: .init(key: .init($0), value: .init($0))) })
    }
}
