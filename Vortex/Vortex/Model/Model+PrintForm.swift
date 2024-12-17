//
//  Model+PrintForm.swift
//  ForaBank
//
//  Created by Max Gribov on 04.07.2022.
//

import Foundation

extension ModelAction {
    
    enum PrintForm {
    
        struct Request: Action {
            
            let paymentOperationDetailId: Int
            let printFormType: PrintFormType
        }
        
        struct Response: Action {
            
            let result: Result<Data, Error>
        }
    }
}

extension Model {
    
    func handlePrintFormRequest(_ payload: ModelAction.PrintForm.Request) {
        
        guard let token = token else {
            handledUnauthorizedCommandAttempt()
            return
        }
        
        let command = ServerCommands.PrintFormController.GetPrintForm(token: token, payload: .init(paymentOperationDetailId: payload.paymentOperationDetailId, printFormType: payload.printFormType))
        serverAgent.executeDownloadCommand(command: command) {[unowned self] result in
            
            switch result {
            case .success(let data):
                action.send(ModelAction.PrintForm.Response(result: .success(data)))
                
            case .failure(let error):
                action.send(ModelAction.PrintForm.Response(result: .failure(error)))
            }
        }
    }
}
