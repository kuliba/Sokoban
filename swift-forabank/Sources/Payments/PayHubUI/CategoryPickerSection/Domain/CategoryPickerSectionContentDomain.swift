//
//  CategoryPickerSectionContentDomain.swift
//
//
//  Created by Igor Malyarov on 28.09.2024.
//

public typealias CategoryPickerSectionContentDomain<Category> = CategoryPickerContentDomain<Category, All>

public struct All: Equatable {
    
    public init() {}
}
