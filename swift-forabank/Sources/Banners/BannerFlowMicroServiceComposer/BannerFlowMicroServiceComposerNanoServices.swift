//
//  BannerFlowMicroServiceComposerNanoServices.swift
//  
//
//  Created by Andryusina Nataly on 10.09.2024.
//

public struct BannerFlowMicroServiceComposerNanoServices<Standard, Sticker> {
    
    public let makeStandard: MakeStandard
    public let makeSticker: MakeSticker
    
    public init(
        makeStandard: @escaping MakeStandard,
        makeSticker: @escaping MakeSticker
    ) {
        self.makeStandard = makeStandard
        self.makeSticker = makeSticker
    }
}

public extension BannerFlowMicroServiceComposerNanoServices {
    
    typealias Make<T> = (@escaping (T) -> Void) -> Void
    
    typealias MakeStandard = Make<Standard>
    typealias MakeSticker = Make<Sticker>
}
