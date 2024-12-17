//
//  AntifraudViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 15.12.2021.
//


import Combine
import UIKit

final class AntifraudViewModel: Identifiable, ObservableObject{

    let action: PassthroughSubject<Action, Never> = .init()

    let phoneNumber: String
    let name: String
    let amount: String
    let status: String?

    lazy var dismissAction: () -> Void = {[weak self] in
        self?.action.send(AntifraudViewModelAction.Dismiss())
    }
    
    lazy var timerAction: () -> Void = {[weak self] in
        self?.action.send(AntifraudViewModelAction.TimerDismiss())
    }
    
    lazy var cancelAction: () -> Void = {[weak self] in
        self?.action.send(AntifraudViewModelAction.Cancel())
    }
    
    var model: CreateSFPTransferDecodableModel
    
    init(model: CreateSFPTransferDecodableModel, phoneNumber: String) {
        
        self.model = model
        self.amount = "- \(model.data?.amount?.currencyFormatter(symbol: model.data?.currencyAmount ?? "") ?? "")"
        self.name = "\(model.data?.payeeName ?? "")"
        self.phoneNumber = phoneNumber
        let data = model.data?.additionalList?.filter({$0.fieldName == "AFResponse"})
        self.status = data?[0].fieldValue
//        self.dismissAction = dismissAction
        

    }
    

}

enum AntifraudViewModelAction {

    struct Dismiss: Action {}
    struct Cancel: Action {}
    struct TimerDismiss: Action {}

    
}
