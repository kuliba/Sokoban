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
 
    func makeUIViewController(context: Context) -> UIViewController {
        
        guard let controller = InternetTVMainController.storyboardInstance() else {
            return UIViewController()
        }
        controller.operatorsViewModel = viewModel
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.searchController = vc.navigationItem.searchController
            vc.parent?.navigationItem.hidesSearchBarWhenScrolling = vc.navigationItem.hidesSearchBarWhenScrolling
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

struct OperatorsViewModel {

    let mode:  Mode
    var closeAction: () -> Void
    var requisitsViewAction: () throws -> Void
    
    enum Mode {
        
        case general
        case template(PaymentTemplateData)
        case qr(QRCode)
    }
    
    init( mode: Mode, closeAction: @escaping () -> Void, requisitsViewAction: @escaping () -> Void) {

        self.mode = mode
        self.closeAction = closeAction
        self.requisitsViewAction = requisitsViewAction
    }
    
    init(mode: Mode, paymentServiceData: PaymentServiceData, model: Model, closeAction: @escaping () -> Void, requisitsViewAction: @escaping () -> Void) {
        
        self.init(mode: mode, closeAction: closeAction, requisitsViewAction: requisitsViewAction)

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
