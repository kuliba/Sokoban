//
//  ServerCommands+PrintForm.swift
//  Vortex
//
//  Created by Max Gribov on 02.02.2022.
//

import Foundation
import ServerAgent

extension ServerCommands {
    
    enum PrintFormController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PrintFormController/getPrintFormUsingPOST
         */
        struct GetPrintForm: ServerDownloadCommand {
            
            let token: String
            let endpoint = "/rest/getPrintForm"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
            
            struct Payload: Encodable {
                
                typealias PrintFormType = String
                
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
