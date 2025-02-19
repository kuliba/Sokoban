//
//  FormContentEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import Foundation

public final class FormContentEffectHandler<Landing, InformerPayload> {
    
    private let load: Load
    private var oldLanding: Landing? = nil
    private let getVerificationCode: GetVerificationCode

    public init(
        load: @escaping Load,
        getVerificationCode: @escaping GetVerificationCode
    ) {
        self.load = load
        self.getVerificationCode = getVerificationCode
    }
}

public extension FormContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case .load:
            load({ dispatch(.dismissInformer(self.oldLanding)) }) { [weak self] in
                switch $0 {
                    
                case let .failure(backendFailure):
                    dispatch(.failure(backendFailure))
                    
                case let .success(landing):
                    self?.oldLanding = landing
                    dispatch(.loaded(landing))
                }
            }
        case .dismissInformer:
            dispatch(.dismissInformer(oldLanding))
            
        case .getVerificationCode:
            getVerificationCode {
                dispatch(.verificationCode($0))
            }
        }
    }
}

public extension FormContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SavingsAccountContentEvent<Landing, InformerPayload>
    typealias Effect = SavingsAccountContentEffect
    
    typealias DismissInformer = () -> Void
    typealias LoadLandingCompletion = (Result<Landing, BackendFailure<InformerPayload>>) -> Void
    typealias Load = (@escaping DismissInformer, @escaping LoadLandingCompletion) -> Void
    
    typealias GetVerificationCodeResult = Result<Int, BackendFailure<InformerPayload>>
    typealias GetVerificationCodeCompletion = (GetVerificationCodeResult) -> Void
    typealias GetVerificationCode = (@escaping GetVerificationCodeCompletion) -> Void
}
