//
//  GIBDDFineDetailsView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 28.06.2022.
//

import Foundation
import SwiftUI

struct GIBDDFineDetailsView: UIViewControllerRepresentable {
    
    let viewModel: GIBDDFineDetailsViewModel
    
    func makeUIViewController(context: Context) -> GIBDDFineDetailsFormController {
        
        let vc = GIBDDFineDetailsFormController.storyboardInstance()!
        if let template = viewModel.paymentTemplate {
            
            vc.template = template
            vc.operatorData = viewModel.latestOpsDO?.op
            vc.latestOperation = viewModel.latestOpsDO
        }
        vc.modalPresentationStyle = .fullScreen
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: GIBDDFineDetailsFormController, context: Context) {}
}

struct GIBDDFineDetailsViewModel {
    
    let closeAction: () -> Void
    let paymentTemplate: PaymentTemplateData?
    var latestOpsDO: InternetLatestOpsDO?
    
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
                    amount: parameterList.amountString,
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
    
    func getOperatorsList(model: Model) -> [GKHOperatorsModel] {
        
        let operators = (model.dictionaryAnywayOperatorGroups()?.compactMap { $0.returnOperators() }) ?? []
        let operatorCodes = [GlobalModule.UTILITIES_CODE, GlobalModule.INTERNET_TV_CODE, GlobalModule.PAYMENT_TRANSPORT]
        let parameterTypes = ["INPUT"]
        let operatorsList = GKHOperatorsModel.childOperators(with: operators, operatorCodes: operatorCodes, parameterTypes: parameterTypes)
        return operatorsList
    }
}
