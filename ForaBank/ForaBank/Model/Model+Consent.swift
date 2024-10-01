//
//  Model+Consent.swift
//  ForaBank
//
//  Created by Дмитрий on 15.07.2022.
//

import Foundation

extension ModelAction {
    
    enum Consent {
        
        enum Me2MePull {
            
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<ConsentMe2MePullData, Error>
            }
        }
        
        enum Me2MeDebit {
            
            struct Request: Action {
                
                let bankid: String
            }
            
            struct Response: Action {
                
                let result: Result<ConsentMe2MeDebitData, Error>
            }
        }
    }
}

extension Model {
    
    func handleConsentMe2MePull() {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.ConsentController.GetClientConsentMe2MePull(token: token)
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let data):
                
                if let me2mePull = data.data, let consentData = me2mePull.consentList?.first {
                    
                    action.send(ModelAction.Consent.Me2MePull.Response(result: .success(consentData)))
                }
                
            case .failure(let error):
                action.send(ModelAction.Consent.Me2MePull.Response(result: .failure(error)))
            }
        }
    }
    
    func handleConsentGetMe2MeDebit(_ payload: ModelAction.Consent.Me2MeDebit.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.ConsentController.GetMe2MeDebitConsent(token: token, payload: .init(bankId: payload.bankid))
        serverAgent.executeCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let data):
                
                if let me2meDebit = data.data {
                    
                    action.send(ModelAction.Consent.Me2MeDebit.Response(result: .success(me2meDebit)))
                }
                
            case .failure(let error):
                action.send(ModelAction.Consent.Me2MeDebit.Response(result: .failure(error)))
            }
        }
    }
}
