//
//  InternetTVDetailsView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 28.06.2022.
//

import Foundation
import SwiftUI

struct InternetTVDetailsView: UIViewControllerRepresentable {
    
    let viewModel: InternetTVDetailsViewModel
    
    func makeUIViewController(context: Context) -> InternetTVDetailsFormController {
        
        let vc = InternetTVDetailsFormController.storyboardInstance()!
        
        vc.operatorData = viewModel.operatorData
        vc.qrData = viewModel.qrData
        vc.operatorsViewModel = viewModel.operatorsViewModel
        
        if let template = viewModel.paymentTemplate {
            
            vc.template = template
            vc.operatorData = viewModel.latestOpsDO?.op
            vc.latestOperation = viewModel.latestOpsDO
            vc.viewModel.closeAction = viewModel.closeAction
        }
        
        vc.modalPresentationStyle = .fullScreen
        context.coordinator.parentObserver = vc.observe(\.parent, changeHandler: { vc, _ in
            
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.title = vc.navigationItem.title
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: InternetTVDetailsFormController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

struct InternetTVDetailsViewModel {
    
    var closeAction: () -> Void = {}
    var paymentTemplate: PaymentTemplateData? = nil
    var latestOpsDO: InternetLatestOpsDO? = nil
    
    var operatorData: GKHOperatorsModel? = nil
    var qrData = [String: String]()
    var operatorsViewModel: OperatorsViewModel? = nil

    
    init(model: Model, closeAction: @escaping () -> Void, paymentTemplate: PaymentTemplateData? = nil, latestOpsDO: InternetLatestOpsDO? = nil) {
        
        self.closeAction = closeAction
        self.paymentTemplate = paymentTemplate
        
        if let parameterList = paymentTemplate?.parameterList.first as? TransferAnywayData {
            
            let operatorsList = getOperatorsList(model: model)
            
            if let foundedOperator = operatorsList.first(where: { $0.puref == parameterList.puref }) {
                
                var image = UIImage(named: "GKH")

                if let svgImage = foundedOperator.logotypeList.first?.svgImage, svgImage != "" {
                
                    image = svgImage.convertSVGStringToImage()
                }
                
                var additionalList = [AdditionalListModel]()
                
                parameterList.additional.forEach { item in
                    let additionalItem = AdditionalListModel()
                    additionalItem.fieldValue = item.fieldvalue
                    additionalItem.fieldName = item.fieldname
                    additionalItem.fieldTitle = item.fieldname
                    additionalList.append(additionalItem)
                }
                
                self.latestOpsDO = InternetLatestOpsDO(
                    mainImage: image ?? UIImage(),
                    name: foundedOperator.name?.capitalizingFirstLetter() ?? "",
                    amount: String(Int(parameterList.amount ?? 0)),
                    op: foundedOperator,
                    additionalList: additionalList)
            }
        }
    }
    
    init(model: Model, closeAction: @escaping () -> Void, paymentServiceData: PaymentServiceData, paymentTemplate: PaymentTemplateData? = nil, latestOpsDO: InternetLatestOpsDO? = nil) {
        
        self.closeAction = closeAction
        self.paymentTemplate = nil
        self.latestOpsDO = nil
        
        let amount = "\(paymentServiceData.amount)"
        var name = ""
        var image: UIImage
        
        let operatorsList = getOperatorsList(model: model)
        let operatorsArray = operatorsList.filter { item in
            item.puref == paymentServiceData.puref }
        
        if operatorsArray.count > 0, let foundedOperator = operatorsArray.first {
            
            name = foundedOperator.name?.capitalizingFirstLetter() ?? ""
            
            if let svgImage = foundedOperator.logotypeList.first?.svgImage, svgImage != "" {
                image = svgImage.convertSVGStringToImage()
            } else {
                image = UIImage(named: "GKH") ?? UIImage()
            }
            
            var additionalList = [AdditionalListModel]()
            paymentServiceData.additionalList.forEach { item in
                let additionalItem = AdditionalListModel()
                additionalItem.fieldValue = item.fieldValue
                additionalItem.fieldName = item.fieldName
                additionalItem.fieldTitle = item.fieldName
                additionalList.append(additionalItem)
            }
            
            let latestOpsDO = InternetLatestOpsDO(mainImage: image, name: name, amount: amount, op: foundedOperator, additionalList: additionalList)
            InternetTVMainViewModel.latestOp = latestOpsDO
            InternetTVMainViewModel.filter = foundedOperator.parentCode ?? GlobalModule.UTILITIES_CODE
        }
    }
    
    init(model: Model, qrCode: QRCode, mapping: QRMapping) {

        let inn = qrCode.stringValue(type: .general(.inn), mapping: mapping)
        var operatorsModel = GKHOperatorsModel()
        let operatorsList = InternetTVMainController.getOperatorsList(model: model)
        operatorsList.forEach( { operators in
            if operators.synonymList.first == inn {
                operatorsModel = operators
            }
        })
        
        self.qrData = qrCode.rawData
        self.operatorData = operatorsModel
        self.operatorsViewModel = nil
    }
    
    init(model: Model, operatorData: OperatorGroupData.OperatorData, closeAction: @escaping () -> Void) {
        
        self.operatorData = .init(with: operatorData, and: nil)
    }
    
    func getOperatorsList(model: Model) -> [GKHOperatorsModel] {
        
        let operators = (model.dictionaryAnywayOperatorGroups()?.compactMap { $0.returnOperators() }) ?? []
        let operatorCodes = [GlobalModule.UTILITIES_CODE, GlobalModule.INTERNET_TV_CODE, GlobalModule.PAYMENT_TRANSPORT]
        let parameterTypes = ["INPUT"]
        let operatorsList = GKHOperatorsModel.childOperators(with: operators, operatorCodes: operatorCodes, parameterTypes: parameterTypes)
        return operatorsList
    }
}
