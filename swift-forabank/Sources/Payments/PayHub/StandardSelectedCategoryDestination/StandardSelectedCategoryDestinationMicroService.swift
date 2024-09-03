//
//  StandardSelectedCategoryDestinationMicroService.swift
//
//
//  Created by Igor Malyarov on 02.09.2024.
//

public struct StandardSelectedCategoryDestinationMicroService<Category, Success, Failure: Error> {
    
    public let makeDestination: MakeDestination
    
    public init(
        makeDestination: @escaping MakeDestination
    ) {
        self.makeDestination = makeDestination
    }
}

public extension StandardSelectedCategoryDestinationMicroService {
    
    typealias MakeDestinationCompletion = (Result<Success, Failure>) -> Void
    typealias MakeDestination = (Category, @escaping MakeDestinationCompletion) -> Void
}
