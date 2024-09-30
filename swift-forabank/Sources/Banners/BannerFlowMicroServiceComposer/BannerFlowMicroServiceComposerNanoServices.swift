//
//  BannerFlowMicroServiceComposerNanoServices.swift
//  
//
//  Created by Andryusina Nataly on 10.09.2024.
//

public struct BannerFlowMicroServiceComposerNanoServices<Standard, Sticker, Landing> {
    
    public let makeStandard: MakeStandard
    public let makeSticker: MakeSticker
    public let makeLanding: MakeLanding

    public init(
        makeStandard: @escaping MakeStandard,
        makeSticker: @escaping MakeSticker,
        makeLanding: @escaping MakeLanding
    ) {
        self.makeStandard = makeStandard
        self.makeSticker = makeSticker
        self.makeLanding = makeLanding
    }
}

public extension BannerFlowMicroServiceComposerNanoServices {
    
    typealias Make<T> = (@escaping (T) -> Void) -> Void
    
    typealias MakeStandard = Make<Standard>
    typealias MakeSticker = Make<Sticker>
    typealias MakeLanding = Make<Landing>
}
