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
        let printFormType: String
    }
    
    struct ShowInfo: Action {
        
        let viewModel: OperationDetailInfoViewModel
    }
    
    struct Change: Action {
        var amount: String
        var name: String
        var surname: String
        var secondName: String
        var paymentOperationDetailId: Int
        var transferReference: String
        var product: UserAllCardsModel
    }
    
    struct Return: Action {
        var amount: String
        let fullName: String
        var name: String
        var surname: String
        var secondName: String
        var paymentOperationDetailId: Int
        var transferReference: String
        var product: UserAllCardsModel
    }
    
    struct CopyNumber: Action {
        
        let number: String
    }
}
