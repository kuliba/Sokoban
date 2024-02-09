//
//  ConsentListRxEffectHandler.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 15.01.2024.
//

import Tagged

public final class ConsentListRxEffectHandler {
    
    private let changeConsentList: ChangeConsentList
    
    public init(changeConsentList: @escaping ChangeConsentList) {
        
        self.changeConsentList = changeConsentList
    }
}

public extension ConsentListRxEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .apply(consent):
            changeConsentList(consent) { result in
                
                switch result {
                case let .failure(serviceFailure):
                    dispatch(.changeConsentFailure(serviceFailure))
                    
                case .success:
                    dispatch(.changeConsent(consent))
                }
            }
        }
    }
}

public extension ConsentListRxEffectHandler {
    
    typealias ChangeConsentListPayload = Set<Bank.ID>
    // (h) changeClientConsentMe2MePull
    typealias ChangeConsentListResponse = Result<OK, ServiceFailure>
    typealias ChangeConsentList = (ChangeConsentListPayload, @escaping (ChangeConsentListResponse) -> Void) -> Void
    
    struct OK {
        
        public init() {}
    }
}

public extension ConsentListRxEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = ConsentListState
    typealias Event = ConsentListEvent
    typealias Effect = ConsentListEffect
}
