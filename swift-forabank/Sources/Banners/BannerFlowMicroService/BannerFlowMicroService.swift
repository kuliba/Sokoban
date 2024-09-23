//
//  BannerFlowMicroService.swift
//
//
//  Created by Andryusina Nataly on 10.09.2024.
//

public struct BannerFlowMicroService<Standard, Sticker> {
    
    public let makeBannerFlow: MakeBannerFlow
    
    public init(
        makeBannerFlow: @escaping MakeBannerFlow
    ) {
        self.makeBannerFlow = makeBannerFlow
    }
}

public extension BannerFlowMicroService {
    
    typealias Flow = BannerFlow< Standard, Sticker>
    typealias MakeBannerFlow = (BannerFlowID, @escaping (Flow) -> Void) -> Void
}
