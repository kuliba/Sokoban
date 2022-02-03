//
//  TemplatesListViewHostingViewController.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation
import SwiftUI
import Combine

class TemplatesListViewHostingViewController: UIHostingController<TemplatesListView> {
    
    var delegate: TemplatesListViewHostingViewControllerDelegate?
    private let viewModel: TemplatesListViewModel
    private var bindings = Set<AnyCancellable>()
    
    init(with viewModel: TemplatesListViewModel) {
        
        self.viewModel = viewModel
        super.init(rootView: TemplatesListView(viewModel: viewModel))
        
        bind()
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TemplatesListViewHostingViewController {
    
    func bind() {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
            
                switch action {
                //TODO: move this to view model after tests
//                case let payload as TemplatesListViewModelAction.ItemTapped:
//                    let model = Model.shared
//                    guard let temp = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == payload.itemId}) else { return }
//
//                    //                    let paymentViewModel = PaymentByPhoneViewModel(phoneNumber: "9279890100", bankId: "0115110217", amount: 1000.22)
//                    let paymentViewModel = PaymentByPhoneViewModel(template: temp)
//                    let paymentViewController = PaymentByPhoneViewController(viewModel: paymentViewModel)
//                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentSFP:
                    let paymentViewController = PaymentByPhoneViewController(viewModel: payload.viewModel)
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentInsideBankByPhone:
                    let paymentViewController = PaymentByPhoneViewController(viewModel: payload.viewModel)
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentInsideBankByCard:
                    let paymentViewController = MemeDetailVC(paymentTemplate: payload.viewModel)
                    //TODO: выбор варианта отображения
//                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
//                    self.dismiss(animated: true) {
                        present(paymentViewController, animated: true)
//                    }
                    
                case _ as TemplatesListViewModelAction.AddTemplate:
                    dismiss(animated: true) { [weak self] in
                        self?.delegate?.presentProductViewController()
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    
    }
}

protocol TemplatesListViewHostingViewControllerDelegate: AnyObject {
    
    func presentProductViewController()
}
