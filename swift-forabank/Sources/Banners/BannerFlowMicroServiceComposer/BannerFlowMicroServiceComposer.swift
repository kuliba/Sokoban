//
//  BannerFlowMicroServiceComposer.swift
//
//
//  Created by Andryusina Nataly on 10.09.2024.
//

public final class BannerFlowMicroServiceComposer<Standard, Sticker, Landing> {
    
    private let nanoServices: NanoServices
    
    public init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = BannerFlowMicroServiceComposerNanoServices<Standard, Sticker, Landing>
}

public extension BannerFlowMicroServiceComposer {
    
    func compose() -> MicroService {
        
        return .init(makeBannerFlow: makeBannerFlow)
    }
    
    typealias MicroService = BannerFlowMicroService<Standard, Sticker, Landing>
}

private extension BannerFlowMicroServiceComposer {
    
    typealias Flow = MicroService.Flow
    
    func makeBannerFlow(
        type: BannerFlowID,
        completion: @escaping (MicroService.Flow) -> Void
    ) {
        switch type {

        case .standard:
            nanoServices.makeStandard { completion(.standard($0)) }
            
        case .sticker:
            nanoServices.makeSticker { completion(.sticker($0)) }
            
        case .landing:
            nanoServices.makeLanding { completion(.landing($0)) }
        }
    }
}
