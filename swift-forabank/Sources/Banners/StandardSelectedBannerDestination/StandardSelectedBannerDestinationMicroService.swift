//
//  StandardSelectedBannerDestinationMicroService.swift
//  
//
//  Created by Andryusina Nataly on 09.09.2024.
//

public struct StandardSelectedBannerDestinationMicroService<Banner, Success, Failure: Error> {
    
    public let makeDestination: MakeDestination
    
    public init(
        makeDestination: @escaping MakeDestination
    ) {
        self.makeDestination = makeDestination
    }
}

public extension StandardSelectedBannerDestinationMicroService {
    
    typealias MakeDestinationCompletion = (Result<Success, Failure>) -> Void
    typealias MakeDestination = (Banner, @escaping MakeDestinationCompletion) -> Void
}
