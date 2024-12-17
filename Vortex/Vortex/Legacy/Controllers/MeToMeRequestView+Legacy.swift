//
//  MeToMeRequestView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 15.07.2022.
//

import Foundation
import SwiftUI

struct MeToMeRequestView: UIViewControllerRepresentable {
    
    var viewModel: RequestMeToMeModel
    
    func makeUIViewController(context: Context) -> MeToMeRequestController {
        
        let controller = MeToMeRequestController()
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
        
        
        let cardId = viewModel.userInfo?["cardId"] as? String ?? ""
        let accountId = viewModel.userInfo?["accountId"] as? String ?? ""
        
        if let viewModelCard = findProduct(with: Int(cardId), with: Int(accountId)) {

            controller.viewModel?.card = viewModelCard
        }
        
        func cards() ->  [UserAllCardsModel] {

            var products: [UserAllCardsModel] = []
            let types: [ProductType] = [.card, .account]
            types.forEach { type in

                products.append(contentsOf: AppDelegate.shared.model.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
            }

            return products
        }
        
        func findProduct(with cardId: Int?, with accountId: Int?) -> UserAllCardsModel? {
            let cardList = cards()
            var card: UserAllCardsModel?
            cardList.forEach { product in
                if cardId != nil {
                    if product.id == cardId {
                        card = product
                    }
                } else {
                    if product.id == accountId {
                        card = product
                    }
                }
            }
            if card == nil {
                card = cardList.first
            }
            return card
        }
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MeToMeRequestController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
    
}

