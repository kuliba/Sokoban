//
//  BannerFlow.swift
//
//
//  Created by Andryusina Nataly on 09.09.2024.
//

public enum BannerFlow<Standard, Sticker> {
    
    case standard(Standard)
    case sticker(Sticker)
}

extension BannerFlow: Equatable where Standard: Equatable, Sticker: Equatable {}

extension BannerFlow {
    
    public var id: BannerFlowID {
        
        switch self {
        case .standard: return .standard
        case .sticker:  return .sticker
        }
    }
}
