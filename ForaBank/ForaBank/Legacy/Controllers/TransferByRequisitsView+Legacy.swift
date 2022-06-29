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
    
    func makeUIViewController(context: Context) -> UINavigationController {
        
        let vc = TransferByRequisitesViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel.closeAction = viewModel.closeAction

        if let paymentTemplate = viewModel.paymentTemplate, let parameter = paymentTemplate.parameterList.first as? TransferGeneralData {
                
                if let bik = parameter.payeeExternal?.bankBIC {
                    vc.bikBankField.textField.text = bik
                }
                
                if let account = parameter.payeeExternal?.accountNumber {
                    let mask = StringMask(mask: "00000 000 0 0000 0000000")
                    vc.accountNumber.textField.text = mask.mask(string: account)
                }
                
                if let fullName = parameter.payeeExternal?.name {
                    let full = fullName.components(separatedBy: " ")
                    vc.fio.surname = full[0]
                    vc.fioField.textField.text = full[0]
                    
                    vc.fio.name = full[1]
                    vc.nameField.textField.text = full[1]
                    
                    vc.fio.patronymic = full[2]
                    vc.surField.textField.text = full[2]
                }
                
                if let inn = parameter.payeeExternal?.inn {
                    vc.innField.textField.text = inn
                }
                
                if let kpp = parameter.payeeExternal?.kpp {
                    vc.kppField.textField.text = kpp
                }
        }
        
        let navigation = UINavigationController(rootViewController: vc)
        return navigation
  
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct TransferByRequisitesViewModel {
    
    let closeAction: () -> Void
    
    var paymentTemplate: PaymentTemplateData? = nil
    
    init(closeAction: @escaping () -> Void,paymentTemplate: PaymentTemplateData?) {
        
        self.closeAction = closeAction
        self.paymentTemplate = paymentTemplate
    }
}
