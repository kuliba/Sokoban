//
//  OperationDetailViewModelAction.swift
//  ForaBank
//
//  Created by Max Gribov on 23.12.2021.
//

import Foundation

enum OperationDetailViewModelAction {

    struct Dismiss: Action {}
    
    struct CreateTemplate: Action {}
    
    struct ShowDocument: Action {
        
        let paymentOperationDetailID: Int
    }
    
    struct ShowDetail: Action {
        
        let paymentOperationDetailID: Int
        let printFormType: String
    }
    
    struct Change: Action {
        
        //TODO: change properties
    }
    
    struct Return: Action {
        
        //TODO: return properties
    }
}
