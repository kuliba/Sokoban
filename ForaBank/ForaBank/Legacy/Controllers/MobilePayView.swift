//
//  MobilePayView.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.06.2022.
//

import Foundation
import SwiftUI

struct MobilePayView: UIViewControllerRepresentable {
    
    var viewModel: MobilePayViewModel
    
    func makeUIViewController(context: Context) -> MobilePayViewController {
        
        let controller = MobilePayViewController()
        controller.viewModel = viewModel
        
        switch viewModel.paymentType {
        case .template(let paymentTemplate):
            if let model = paymentTemplate.parameterList.first as? TransferAnywayData {
                    
                    let mask = StringMask(mask: "+7 (000) 000-00-00")
                    let phone = model.additional.first(where: { $0.fieldname == "a3_NUMBER_1_2" })
                    let maskPhone = mask.mask(string: phone?.fieldvalue)
                    
                    controller.selectNumber = maskPhone
                    controller.phoneField.textField.text = maskPhone
            }
            
        case .paymentServiceData(let paymentServiceData):
            
            let phoneNumber = paymentServiceData.additionalList.filter {
                $0.fieldName == "a3_NUMBER_1_2"
            }

            if let number = phoneNumber.first?.fieldValue {
                
                let phoneFormatter = PhoneNumberFormater()
                let formattedPhone = phoneFormatter.format(number)
                controller.phoneField.text = formattedPhone
                controller.selectNumber = formattedPhone
            }
        case .none:
            break
        }
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.title = vc.navigationItem.title
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MobilePayViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

struct MobilePayViewModel {
    
    let closeAction: () -> Void
    let paymentType: PaymentType?
    
    init(paymentTemplate: PaymentTemplateData) {
        
        self.paymentType = .template(paymentTemplate)
        self.closeAction = {}
    }
    
    init(closeAction: @escaping () -> Void) {
        
        self.closeAction = closeAction
        self.paymentType = nil
    }
    
    init(paymentServiceData: PaymentServiceData) {
        
        self.paymentType = .paymentServiceData(paymentServiceData)
        self.closeAction = {}
    }
    
    enum PaymentType {
        
        case template(PaymentTemplateData)
        case paymentServiceData(PaymentServiceData)
    }
}

