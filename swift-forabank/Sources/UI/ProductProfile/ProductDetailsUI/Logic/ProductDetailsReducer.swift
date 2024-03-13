//
//  ProductDetailsReducer.swift
//
//
//  Created by Andryusina Nataly on 08.03.2024.
//

import Foundation

public final class ProductDetailsReducer {
    
    private let shareInfo: ([String]) -> Void
    
    public init(shareInfo: @escaping ([String]) -> Void) {
        self.shareInfo = shareInfo
    }
}

public extension ProductDetailsReducer {
 
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case .appear:
            state.event = .appear
            
        case let .itemTapped(tap):
            switch tap {
            case let .longPress(valueForCopy, text):
                state.event = .itemTapped(.longPress(valueForCopy, text))
                
            case let .iconTap(itemId):
                switch itemId {
                case .number:
                    state.updateDetailsStateByTap(itemId)
                default:
                    state.event = .itemTapped(.iconTap(itemId))
                }
            case .share:
                if state.showCheckBox {
                    shareInfo(state.copyValues())
                } else {
                    state.event = .itemTapped(.share)
                }
                state.showCheckBox = false
                state.title = "Реквизиты счета и карты"
            case let .selectAccountValue(select):
                state.updateShareData(.needAddAccountInfo(select))
            case let .selectCardValue(select):
                state.updateShareData(.needAddCardInfo(select))
            }
        case .sendAll:
            state.event = .sendAll
        case .sendSelect:
            state.event = .sendSelect
            state.showCheckBox = true
            state.title = "Выберите реквизиты"
        case .close:
            state.event = .close
        case .hideCheckbox:
            state.showCheckBox = false
            state.title = "Реквизиты счета и карты"
        }
        
        return (state, .none)
    }
}

public extension ProductDetailsReducer {
    
    typealias State = ProductDetailsState
    typealias Event = ProductDetailsEvent
    typealias Effect = ProductDetailsEffect

    typealias Reduce = (State, Event) -> (State, Effect?)
}
