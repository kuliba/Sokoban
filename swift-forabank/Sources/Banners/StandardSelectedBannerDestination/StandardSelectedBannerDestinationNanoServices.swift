//
//  StandardSelectedBannerDestinationNanoServices.swift
//
//
//  Created by Andryusina Nataly on 09.09.2024.
//

public struct StandardSelectedBannerDestinationNanoServices<Banner, Success, Failure> {
    
    public let makeFailure: MakeFailure
    public let makeSuccess: MakeSuccess
    
    public init(
        makeFailure: @escaping MakeFailure,
        makeSuccess: @escaping MakeSuccess
    ) {
        self.makeFailure = makeFailure
        self.makeSuccess = makeSuccess
    }
}

public extension StandardSelectedBannerDestinationNanoServices {
        
    typealias MakeFailure = (@escaping (Failure) -> Void) -> Void
    
    typealias MakeSuccessPayload = MakeSelectedBannerSuccessPayload<Banner>
    typealias MakeSuccess = (MakeSuccessPayload, @escaping (Success) -> Void) -> Void
}
