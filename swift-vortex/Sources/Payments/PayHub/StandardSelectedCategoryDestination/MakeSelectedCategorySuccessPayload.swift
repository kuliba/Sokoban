//
//  MakeSelectedCategorySuccessPayload.swift
//
//
//  Created by Igor Malyarov on 03.09.2024.
//

public struct MakeSelectedCategorySuccessPayload<Category, Latest, Operator> {
    
    public let category: Category
    public let latest: [Latest]
    public let operators: [Operator]
    
    public init(
        category: Category,
        latest: [Latest],
        operators: [Operator]
    ) {
        self.category = category
        self.latest = latest
        self.operators = operators
    }
}

extension MakeSelectedCategorySuccessPayload: Equatable where Category: Equatable, Latest: Equatable, Operator: Equatable {}
