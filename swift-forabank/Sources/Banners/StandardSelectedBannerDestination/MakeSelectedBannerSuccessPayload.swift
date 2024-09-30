//
//  MakeSelectedBannerSuccessPayload.swift
//
//
//  Created by Andryusina Nataly on 09.09.2024.
//

public struct MakeSelectedBannerSuccessPayload<Banner> {
    
    public let banner: Banner
    
    public init(
        banner: Banner
    ) {
        self.banner = banner
    }
}

extension MakeSelectedBannerSuccessPayload: Equatable where Banner: Equatable {}
