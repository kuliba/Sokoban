//
//  LandingEvent.swift
//  
//
//  Created by Igor Malyarov on 04.09.2023.
//

// TODO: - add cases for limits

public enum LandingEvent: Equatable {
    
    case card(Card)
    case sticker(Sticker)
    case bannerAction(BannerAction)
    case listVerticalRoundImageAction(ListVerticalRoundImageAction)

    public enum Card: Equatable {
        
        case goToMain
        case openUrl(String)
        case order(cardTarif: Int, cardType: Int)
    }
    
    public enum Sticker: Equatable {
        
        case goToMain
        case order
    }
    
    public enum BannerAction: Equatable {
        
        case contact(Country)
        case depositsList
        case depositTransfer
        case landing
        case migAuthTransfer
        case migTransfer(Country)
        case openDeposit(Deposit)
    }
    
    public struct Country: Equatable {
        public let countryID: String
    }
    
    public struct Deposit: Equatable {
        public let depositID: Int
    }
    
    public enum ListVerticalRoundImageAction: Equatable {
        
        case openSubscriptions
    }
}
