//
//  TemplatesListViewHostingViewController.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

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
                    let model = ConfirmViewControllerModel(type: .card2card, status: .succses)
                    let paymentViewController = CustomPopUpWithRateView(paymentTemplate: payload.viewModel)
                    paymentViewController.viewModel = model
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.MobilePayment:
                    let paymentViewController = MobilePayViewController(paymentTemplate: payload.viewModel)
                    navigationController?.pushViewController(paymentViewController, animated: true)
                    
                case let payload as TemplatesListViewModelAction.Present.InterneetPayment:
                    let templateModel = payload.viewModel
                    openLatestUtilities(template: templateModel)
                    
                case let payload as TemplatesListViewModelAction.Present.GKHPayment:
                    let templateModel = payload.viewModel
                    openLatestUtilities(template: templateModel)
                    
                case let payload as TemplatesListViewModelAction.Present.TransportPayment:
                    let templateModel = payload.viewModel
                    openLatestUtilities(template: templateModel)
                    
                case let payload as TemplatesListViewModelAction.OpenProductProfile:
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
    //PaymentTemplateData
    private func openLatestUtilities(template: PaymentTemplateData) {
        var amount = ""
        var name = ""
        var image: UIImage!
        let realm = try? Realm()
        
        if let parameterList = template.parameterList.first as? TransferAnywayData {
            amount = parameterList.amountString
            let operators = realm?.objects(GKHOperatorsModel.self)
            
            if let foundedOperator = operators?.first(where: { $0.puref == parameterList.puref }) {
                
                name = foundedOperator.name?.capitalizingFirstLetter() ?? ""
                
                if let svgImage = foundedOperator.logotypeList.first?.svgImage, svgImage != "" {
                    image = svgImage.convertSVGStringToImage()
                } else {
                    image = UIImage(named: "GKH")
                }
                var additionalList = [AdditionalListModel]()
                
                parameterList.additional.forEach { item in
                    let additionalItem = AdditionalListModel()
                    additionalItem.fieldValue = item.fieldvalue
                    additionalItem.fieldName = item.fieldname
                    additionalItem.fieldTitle = item.fieldname
                    additionalList.append(additionalItem)
                }
                
                let latestOpsDO = InternetLatestOpsDO(
                    mainImage: image,
                    name: name,
                    amount: amount,
                    op: foundedOperator,
                    additionalList: additionalList)
                
                if "iFora||AVDТ;iFora||AVDD".contains(parameterList.puref ?? "-1" ) == true {
                    
                    guard let controller = AvtodorDetailsFormController.storyboardInstance() else { return }
                    controller.operatorData = latestOpsDO.op
                    controller.latestOperation = latestOpsDO
                    controller.template = template
                    navigationController?.pushViewController(controller, animated: true)
                    
                } else if parameterList.puref == "iFora||5173" {
                    
                    guard let controller = GIBDDFineDetailsFormController.storyboardInstance() else { return }
                    controller.operatorData = latestOpsDO.op
                    controller.latestOperation = latestOpsDO
                    controller.template = template
                    navigationController?.pushViewController(controller, animated: true)
                    
                } else {
                    
                    guard let controller = InternetTVDetailsFormController.storyboardInstance() else { return }
                    controller.operatorData = latestOpsDO.op
                    controller.latestOperation = latestOpsDO
                    controller.template = template
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

protocol TemplatesListViewHostingViewControllerDelegate: AnyObject {
    
    func presentProductViewController()
}
