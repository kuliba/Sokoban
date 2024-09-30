//
//  StandardSelectedBannerDestinationMicroServiceComposer.swift
//  
//
//  Created by Andryusina Nataly on 09.09.2024.
//

public final class StandardSelectedBannerDestinationMicroServiceComposer<Banner, Success, Failure: Error> {
    
    private let nanoServices: NanoServices
    
    public init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = StandardSelectedBannerDestinationNanoServices<Banner, Success, Failure>
}

public extension StandardSelectedBannerDestinationMicroServiceComposer {
    
    func compose() -> MicroService {
        
        return .init(makeDestination: makeDestination)
    }
    
    typealias MicroService = StandardSelectedBannerDestinationMicroService<Banner, Success, Failure>
}

private extension StandardSelectedBannerDestinationMicroServiceComposer {
    
    func makeDestination(
        banner: Banner,
        completion: @escaping MicroService.MakeDestinationCompletion
    ) {
            handle(banner, completion)
    }
    
    func handle(
        _ banner: Banner,
        _ completion: @escaping MicroService.MakeDestinationCompletion
    ) {
        nanoServices.makeSuccess(.init(
            banner: banner
        )) {
            completion(.success($0))
        }
    }
}
