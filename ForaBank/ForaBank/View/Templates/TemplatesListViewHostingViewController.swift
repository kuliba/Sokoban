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
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentMig:
                    let vc = ContactInputViewController(paymentTemplate: payload.viewModel)
                    navigationController?.pushViewController(vc, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentContact:
                    let vc = ContactInputViewController(paymentTemplate: payload.viewModel)
                    navigationController?.pushViewController(vc, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentRequisites:
                    let paymentViewController = TransferByRequisitesViewController(paymentTemplate: payload.viewModel)
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.OrgPaymentRequisites:
                    let paymentViewController = TransferByRequisitesViewController(orgPaymentTemplate: payload.viewModel)
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentSFP:
                    let paymentViewController = PaymentByPhoneViewController(viewModel: payload.viewModel)
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentInsideBankByPhone:
                    let paymentViewController = PaymentByPhoneViewController(viewModel: payload.viewModel)
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentInsideBankByCard:
                    let paymentViewController = MemeDetailVC(paymentTemplate: payload.viewModel)
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.PaymentToMyCard:
                    let model = ConfirmViewControllerModel(type: .card2card)
                    let paymentViewController = CustomPopUpWithRateView(paymentTemplate: payload.viewModel)
                    paymentViewController.viewModel = model
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                    
                case _ as TemplatesListViewModelAction.AddTemplate:
                    dismiss(animated: true) { [weak self] in
                        self?.delegate?.presentProductViewController()
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    
    }
    
    func getCountry(code: String) -> CountriesList {
        var countryValue: CountriesList?
        let list = Dict.shared.countries
        list?.forEach({ country in
            if country.code == code {
                countryValue = country
            }
        })
        return countryValue!
    }
}

protocol TemplatesListViewHostingViewControllerDelegate: AnyObject {
    
    func presentProductViewController()
}
