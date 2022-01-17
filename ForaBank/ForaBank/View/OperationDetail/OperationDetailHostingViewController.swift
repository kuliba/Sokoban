//
//  OperationDetailHostingViewController.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import UIKit
import SwiftUI
import Combine

class OperationDetailHostingViewController: UIHostingController<OperationDetailView> {
    
    private let viewModel: OperationDetailViewModel
    private var bindings = Set<AnyCancellable>()
    
    init(with viewModel: OperationDetailViewModel) {
        
        self.viewModel = viewModel
        super.init(rootView: OperationDetailView(viewModel: viewModel))
        modalPresentationStyle = .custom
        transitioningDelegate = self
        view.backgroundColor = .clear
        
        bind()
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self = self else {
                    return
                }
                
                switch action {
                case _ as OperationDetailViewModelAction.Dismiss:
                    self.dismiss(animated: true)
                    
                case let payload as OperationDetailViewModelAction.ShowDocument:
                    let pdfViewerVC = PDFViewerViewController()
                    pdfViewerVC.id = payload.paymentOperationDetailID
                    pdfViewerVC.printFormType = payload.printFormType
                    self.present(pdfViewerVC, animated: true)
                    
                case let payload as OperationDetailViewModelAction.Change:
                    //TODO: change action here
                    let confurmVCModel = ConfirmViewControllerModel(type: .contact)
                    confurmVCModel.summTransction = payload.amount
                    confurmVCModel.name = payload.name
                    confurmVCModel.surname = payload.surname
                    confurmVCModel.secondName = payload.secondName
                    confurmVCModel.paymentOperationDetailId = payload.paymentOperationDetailId
                    confurmVCModel.numberTransction = payload.transferReference
                    confurmVCModel.cardFromRealm = payload.product
                    let controller = ChangeReturnCountryController(type: .changePay)
                    controller.confurmVCModel = confurmVCModel
                    self.present(controller, animated: true, completion: nil)
                                        
                case let payload as OperationDetailViewModelAction.Return:
                    let confurmVCModel = ConfirmViewControllerModel(type: .contact)
                    confurmVCModel.summTransction = payload.amount
                    confurmVCModel.fullName = payload.fullName
                    confurmVCModel.name = payload.name
                    confurmVCModel.surname = payload.surname
                    confurmVCModel.secondName = payload.secondName
                    confurmVCModel.paymentOperationDetailId = payload.paymentOperationDetailId
                    confurmVCModel.numberTransction = payload.transferReference
                    confurmVCModel.cardFromRealm = payload.product
                    let controller = ChangeReturnCountryController(type: .returnPay)
                    controller.confurmVCModel = confurmVCModel
                    self.present(controller, animated: true, completion: nil)
                    
                case let payload as OperationDetailViewModelAction.CopyNumber:
                    UIPasteboard.general.string = payload.number
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

extension OperationDetailHostingViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = Int(UIScreen.main.bounds.height)
        
        return presenter
    }
}
