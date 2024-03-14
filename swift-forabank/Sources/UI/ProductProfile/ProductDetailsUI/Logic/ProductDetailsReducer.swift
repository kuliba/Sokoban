//
//  ProductDetailsReducer.swift
//
//
//  Created by Andryusina Nataly on 08.03.2024.
//

import Foundation

public final class ProductDetailsReducer {
    
    private let shareInfo: ShareAction
    
    public init(shareInfo: @escaping ShareAction) {
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
            state.status = .appear
            
        case let .itemTapped(tap):
            switch tap {
            case let .longPress(valueForCopy, text):
                state.status = .itemTapped(.longPress(valueForCopy, text))
            case let .iconTap(itemId):
                switch itemId {
                case .number:
                    state.updateDetailsStateByTap(itemId)
                    state.status = nil
                default:
                    state.status = .itemTapped(.iconTap(itemId))
                }
            case .share:
                if state.showCheckBox {
                    shareInfo(state.copyValues())
                    state.status = nil
                } else {
                    state.status = .itemTapped(.share)
                }
                state.showCheckBox = false
                state.title = "Реквизиты счета и карты"
            case let .selectAccountValue(select):
                state.updateShareData(.needAddAccountInfo(select))
            case let .selectCardValue(select):
                state.updateShareData(.needAddCardInfo(select))
            }
        case .sendAll:
            shareInfo(state.allVallues())
            state.cleanDataForShare()
            state.status = .sendAll
        case .sendSelect:
            state.showCheckBox = true
            state.title = "Выберите реквизиты"
            state.status = .sendSelect
        case .hideCheckbox:
            state.showCheckBox = false
            state.title = "Реквизиты счета и карты"
            state.status = nil
        case .close:
            state.status = .close
        case .closeModal:
            state.status = .closeModal
        }
        
        return (state, .none)
    }
}

public extension ProductDetailsReducer {
    
    typealias State = ProductDetailsState
    typealias Event = ProductDetailsEvent
    typealias Effect = ProductDetailsEffect

    typealias Reduce = (State, Event) -> (State, Effect?)
    
    typealias ShareAction = ([String]) -> Void
}
