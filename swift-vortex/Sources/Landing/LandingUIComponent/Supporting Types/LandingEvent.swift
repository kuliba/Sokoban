//
//  LandingEvent.swift
//  
//
//  Created by Igor Malyarov on 04.09.2023.
//

public enum LandingEvent: Equatable {
    
    case bannerAction(BannerAction)
    case card(Card)
    case goToBack
    case listVerticalRoundImageAction(ListVerticalRoundImageAction)
    case sticker(Sticker)

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
        case payment(String)
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
