//
//  OperatorsView.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.06.2022.
//

import Foundation
import SwiftUI

struct OperatorsView: UIViewControllerRepresentable {
    
    let viewModel: OperatorsViewModel
 
    func makeUIViewController(context: Context) -> InternetTVMainController {
        
        let vc = InternetTVMainController.storyboardInstance()!
        return vc
    }
    
    func updateUIViewController(_ uiViewController: InternetTVMainController, context: Context) {}
}

struct OperatorsViewModel {

    var closeAction: () -> Void
    var template: PaymentTemplateData?
    
    init(closeAction: @escaping () -> Void, template: PaymentTemplateData?) {
        
        self.closeAction = closeAction
        self.template = template
    }
    
    init(model: Model, closeAction: @escaping () -> Void, paymentServiceData: PaymentServiceData, paymentTemplate: PaymentTemplateData? = nil) {
        
        self.closeAction = closeAction
        
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
