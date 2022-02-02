//
//  ServerCommands+PrintForm.swift
//  ForaBank
//
//  Created by Max Gribov on 02.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum PrintFormController {
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PrintFormController/getPrintFormUsingPOST
         */
        struct GetPrintForm: ServerDownloadCommand {

            let token: String
            let endpoint = "/rest/getPrintForm"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let paymentOperationDetailId: Int
                let printFormType: PrintFormType
            }

            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
    }
}
