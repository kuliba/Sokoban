//
//  Model+Consent.swift
//  ForaBank
//
//  Created by Дмитрий on 15.07.2022.
//

import Foundation

extension ModelAction {
    
    enum Consent {
    
        struct Request: Action {}
        
        struct Response: Action {
            
            let result: Result<ConsentMe2MePullData, Error>
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
                    
                        action.send(ModelAction.Consent.Response(result: .success(consentData)))
                }
                
            case .failure(let error):
                action.send(ModelAction.Consent.Response(result: .failure(error)))
            }
        }
    }
}
