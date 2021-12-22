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
                    
                case let payload as OperationDetailViewModelAction.ShowDetail:
                    let pdfViewerVC = PDFViewerViewController()
                    pdfViewerVC.id = payload.paymentOperationDetailID
                    pdfViewerVC.printFormType = payload.printFormType
                    self.present(pdfViewerVC, animated: true)
                    
                case _ as OperationDetailViewModelAction.Change:
                    //TODO: change action here
                    break
                    
                case _ as OperationDetailViewModelAction.Return:
                    //TODO: return action here
                    break
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
}
