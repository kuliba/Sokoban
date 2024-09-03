//
//  CategoryPickerDestinationMicroService.swift
//
//
//  Created by Igor Malyarov on 02.09.2024.
//

public struct CategoryPickerDestinationMicroService<Category, Success, Failure: Error> {
    
    public let makeDestination: MakeDestination
    
    public init(
        makeDestination: @escaping MakeDestination
    ) {
        self.makeDestination = makeDestination
    }
}

public extension CategoryPickerDestinationMicroService {
    
    typealias MakeDestinationCompletion = (Result<Success, Failure>) -> Void
    typealias MakeDestination = (Category, @escaping MakeDestinationCompletion) -> Void
}
