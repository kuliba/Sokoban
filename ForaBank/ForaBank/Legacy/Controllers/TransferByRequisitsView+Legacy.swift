//
//  TransferByRequisitsView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 14.06.2022.
//

import Foundation
import SwiftUI

struct TransferByRequisitesView: UIViewControllerRepresentable {
    
    let viewModel: TransferByRequisitesViewModel
    
    func makeUIViewController(context: Context) -> TransferByRequisitesViewController {
        
        let controller = TransferByRequisitesViewController()
        controller.viewModel.closeAction = viewModel.closeAction

        if let paymentTemplate = viewModel.paymentTemplate, let parameter = paymentTemplate.parameterList.first as? TransferGeneralData {
                
                if let bik = parameter.payeeExternal?.bankBIC {
                    controller.bikBankField.textField.text = bik
                }
                
                if let account = parameter.payeeExternal?.accountNumber {
                    let mask = StringMask(mask: "00000 000 0 0000 0000000")
                    controller.accountNumber.textField.text = mask.mask(string: account)
                }
                
                if let fullName = parameter.payeeExternal?.name {
                    let full = fullName.components(separatedBy: " ")
                    controller.fio.surname = full[0]
                    controller.fioField.textField.text = full[0]
                    
                    controller.fio.name = full[1]
                    controller.nameField.textField.text = full[1]
                    
                    controller.fio.patronymic = full[2]
                    controller.surField.textField.text = full[2]
                }
                
                if let inn = parameter.payeeExternal?.inn {
                    controller.innField.textField.text = inn
                }
                
                if let kpp = parameter.payeeExternal?.kpp {
                    controller.kppField.textField.text = kpp
                }
        }
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: TransferByRequisitesViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

struct TransferByRequisitesViewModel {
    
    let closeAction: () -> Void
    
    var paymentTemplate: PaymentTemplateData? = nil
    
    init(closeAction: @escaping () -> Void,paymentTemplate: PaymentTemplateData?) {
        
        self.closeAction = closeAction
        self.paymentTemplate = paymentTemplate
    }
}
