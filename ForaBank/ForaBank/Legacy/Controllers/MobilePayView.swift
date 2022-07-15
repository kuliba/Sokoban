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
            
            switch viewModel.paymentType {
            case .template(let paymentTemplate):

                let controller = MobilePayViewController(paymentTemplate: paymentTemplate)
                controller.viewModel = viewModel

            context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
                vc.parent?.navigationItem.title = vc.navigationItem.title
                vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
                vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
            })

             return controller
                
            case .paymentServiceData(let paymentServiceData):
                
                let controller = MobilePayViewController()
                controller.viewModel = viewModel

                let phoneNumber = paymentServiceData.additionalList.filter {
                    $0.fieldName == "a3_NUMBER_1_2"
                }

                if let number = phoneNumber.first?.fieldValue {
                    
                    let phoneFormatter = PhoneNumberFormater()
                    let formattedPhone = phoneFormatter.format(number)
                    controller.phoneField.text = formattedPhone
                    controller.selectNumber = formattedPhone
                }

            context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
                vc.parent?.navigationItem.title = vc.navigationItem.title
                vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
                vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
            })
               return controller

            case .none:
               let controller = MobilePayViewController()
                controller.viewModel = viewModel

            context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
                vc.parent?.navigationItem.title = vc.navigationItem.title
                vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
                vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
            })
            
            return controller
            }
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
    
    init(paymentTemplate: PaymentTemplateData, closeAction: @escaping () -> Void) {
        
        self.paymentType = .template(paymentTemplate)
        self.closeAction = closeAction
    }
    
    init(closeAction: @escaping () -> Void) {
        
        self.closeAction = closeAction
        self.paymentType = nil
    }
    
    init(paymentServiceData: PaymentServiceData, closeAction: @escaping () -> Void) {
        
        self.paymentType = .paymentServiceData(paymentServiceData)
        self.closeAction = closeAction
    }
    
    enum PaymentType {
        
        case template(PaymentTemplateData)
        case paymentServiceData(PaymentServiceData)
    }
}

