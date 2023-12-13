//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 03.11.2023.
//

import Foundation

extension Operation.Parameter.Select {
    
    public func updatedStateToList(
        iconName: String
    ) -> Self {
        
        .init(
            id: id,
            value: value,
            title: title,
            placeholder: placeholder,
            options: options,
            staticOptions: staticOptions,
            state: .list(
                .init(
                    iconName: iconName,
                    title: title,
                    placeholder: title,
                    options: options.map(Option.optionViewModelMapper(option:))
                )
            )
        )
    }
    
    public func updatedStateToIdle(
        iconName: String,
        title: String
    ) -> Self {
        
        .init(
            id: id,
            value: value,
            title: title,
            placeholder: placeholder,
            options: options,
            staticOptions: staticOptions,
            state: .idle(
                .init(
                    iconName: iconName,
                    title: title
                )
            )
        )
    }
}
