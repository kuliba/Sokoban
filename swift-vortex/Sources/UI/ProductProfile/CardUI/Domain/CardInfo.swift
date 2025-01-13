//
//  CardInfo.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import Foundation
import Tagged

public struct CardInfo: Equatable {
    
    public typealias CVV = Tagged<_CVV, String>
    public enum _CVV {}
    
    public var name: String
    public var owner: String
    
    public let cvvTitle: CVVTitle
    public var cardWiggle: Bool
    public let fullNumber: FullNumber
    public let numberMasked: MaskedNumber
    public var state: State
    
    public init(
        name: String,
        owner: String,
        cvvTitle: CVVTitle,
        cardWiggle: Bool,
        fullNumber: FullNumber,
        numberMasked: MaskedNumber,
        state: State = .showFront
    ) {
        self.name = name
        self.owner = owner
        self.cvvTitle = cvvTitle
        self.cardWiggle = cardWiggle
        self.fullNumber = fullNumber
        self.numberMasked = numberMasked
        self.state = state
    }
    
    public enum State: Equatable {
        
        case awaitingCVV
        case fullNumberMaskedCVV
        case maskedNumberCVV(CVV)
        case showFront
    }
    
    public struct FullNumber: Equatable {
        
        public let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
    
    public struct MaskedNumber: Equatable {
        
        let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
    
    public struct CVVTitle: Equatable {
        
        let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
    
    public mutating func stateToggle() {
        
        switch state {
            
        case .showFront:
            
            state = .fullNumberMaskedCVV
            
        default:
            
            state = .showFront
        }
    }
}

public extension CardInfo {
    
    var numberToDisplay: String {
        
        switch state {
            
        case .maskedNumberCVV, .awaitingCVV:
            return numberMasked.value
            
        case .fullNumberMaskedCVV, .showFront:
            return fullNumber.value.formatted()
        }
    }
    
    var cvvToDisplay: String {
        
        switch state {
            
        case .fullNumberMaskedCVV, .showFront, .awaitingCVV:
            return cvvTitle.value
            
        case let .maskedNumberCVV(value):
            return value.rawValue
        }
    }
    
    var isShowingCardBack: Bool {
        
        return state != .showFront
    }
}
