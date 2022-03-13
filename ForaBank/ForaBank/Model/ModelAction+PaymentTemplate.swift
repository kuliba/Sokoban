//
//  ModelAction+PaymentTemplate.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

extension ModelAction {
    
    enum PaymentTemplate {
        
        enum Save {
        
            struct Requested: Action {
                
                let name: String
                let paymentOperationDetailId: Int
            }
            
            struct Complete: Action {
                
                let paymentTemplateId: Int
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        
        enum Update {
            
            struct Requested: Action {
                
                let name: String?
                let parameterList: [TransferData]?
                let paymentTemplateId: Int
            }
            
            struct Complete: Action {}
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        
        enum Delete {
            
            struct Requested: Action {
                
                let paymentTemplateIdList: [Int]
            }
            
            struct Complete: Action {}
            
            struct Failed: Action {
                
                let error: Error
            }
        }
        
        enum List {
            
            struct Requested: Action {}
            
            struct Complete: Action {
                
                let paymentTemplates: [PaymentTemplateData]
            }
            
            struct Failed: Action {
                
                let error: Error
            }
        }
    
    }
}
