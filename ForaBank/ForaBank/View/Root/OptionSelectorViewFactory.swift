//
//  OptionSelectorViewFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.11.2024.
//

import Foundation

struct OptionSelectorViewFactory {
    
    let makeCategoryView: MakeCategoryView
}

extension OptionSelectorViewFactory {
    
    static let preview: Self = .init(makeCategoryView: { CategoryView(newImplementation: true, isSelected: $0, title: $1)
    })
}
