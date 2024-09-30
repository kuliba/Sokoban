//
//  BannerFlow.swift
//
//
//  Created by Andryusina Nataly on 09.09.2024.
//

public enum BannerFlow<Standard, Sticker, Landing> {
    
    case standard(Standard)
    case sticker(Sticker)
    case landing(Landing)
}

extension BannerFlow: Equatable where Standard: Equatable, Sticker: Equatable, Landing: Equatable {}

extension BannerFlow {
    
    public var id: BannerFlowID {
        
        switch self {
        case .standard: return .standard
        case .sticker:  return .sticker
        case .landing:  return .landing
        }
    }
}
