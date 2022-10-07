//
//  InfoProductViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 23.05.2022.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class InfoProductViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var title: String
    @Published var list: [ItemViewModel]
    @Published var additionalList: [ItemViewModel]?
    @Published var isShareViewPresented = false
    @Published var alert: Alert.ViewModel?
    var shareButton: ButtonViewModel?
    let product: ProductData
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(product: ProductData, title: String, list: [ItemViewModel], additionalList: [ItemViewModel]?, shareButton: ButtonViewModel?, model: Model) {
        
        self.product = product
        self.title = title
        self.list = list
        self.additionalList = additionalList
        self.shareButton = shareButton
        self.model = model
    }
    
    internal init(model: Model, product: ProductData, info: Bool = true) {
        
        self.model = model
        self.product = product
        self.title = ""
        self.list = []
        
        if let cardProductData = product as? ProductCardData {
            
            self.additionalList = self.setupAdditionalList(for: cardProductData)
        }
        
        self.shareButton = .init(action: { self.isShareViewPresented.toggle() })
        
        bind()
        setBasic(product: product, info: info)
    }
    
    struct ItemViewModel: Hashable {
        
        var title: String
        var subtitle: String
        var button: ButtonItemViewModel?
        
        init(title: String, subtitle: String, button: ButtonItemViewModel? = nil) {
            
            self.title = title
            self.subtitle = subtitle
            self.button = button
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }
        
        static func == (lhs: InfoProductViewModel.ItemViewModel, rhs: InfoProductViewModel.ItemViewModel) -> Bool {
            lhs.title == rhs.title && lhs.subtitle == rhs.subtitle && lhs.button == rhs.button
        }
    }
    
    struct ButtonItemViewModel: Equatable {
        
        var icon: Image
        var action: () -> Void
        
        static func == (lhs: InfoProductViewModel.ButtonItemViewModel, rhs: InfoProductViewModel.ButtonItemViewModel) -> Bool {
            lhs.icon == rhs.icon
        }
    }
    
    struct ButtonViewModel {
        
        let title = "Поделиться"
        var action: () -> Void
    }
    
    private func setBasic(product: ProductData, info: Bool) {
        
        switch product.productType {
        case .card:
            
            model.action.send(ModelAction.Products.ProductDetails.Request(type: product.productType, id: product.id))
            self.title = "Реквизиты счета карты"
        case .account:
            
            model.action.send(ModelAction.Products.ProductDetails.Request(type: .account, id: product.id))
            self.title = "Реквизиты счета"
        case .deposit:
            if info {
                
                self.title = "Информация по вкладу"
                model.action.send(ModelAction.Deposits.Info.Single.Request(productId: product.id))
                self.shareButton = nil
                
            } else {
                
                model.action.send(ModelAction.Products.ProductDetails.Request(type: product.productType, id: product.id))
                self.title = "Реквизиты счета вклада"
                self.shareButton = nil
            }
        case .loan:
            model.action.send(ModelAction.Products.ProductDetails.Request(type: .loan, id: product.id))
            self.title = "Реквизиты счета"
        }
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as InfoProductModelAction.ShowCardNumber:
                    
                    var additionalList: [ItemViewModel] = []
                    
                    if let holderName = payload.productCardData.holderName {
                        
                        additionalList.append(.init(title: "Держатель карты", subtitle: holderName))
                    }
                    
                    if let number = payload.productCardData.number {
                        
                        let mask = StringValueMask.card
                        let maskedNumber = number.masked(mask: mask)
                        
                        UIPasteboard.general.string = maskedNumber
                        additionalList.append(.init(title: "Номер карты", subtitle: maskedNumber, button: .init(icon: .ic24EyeOff, action: { [weak self] in
                            
                            self?.additionalList = self?.setupAdditionalList(for: payload.productCardData)
                        })))
                    }
                    
                    if let expireDate = payload.productCardData.expireDate {
                        
                        additionalList.append(.init(title: "Карта дейстует до", subtitle: expireDate))
                    }
                    
                    withAnimation {
                        
                        self.additionalList = additionalList
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                        
                        withAnimation {
                            
                            self.additionalList = self.setupAdditionalList(for: payload.productCardData)
                        }
                    }

                case let payload as InfoProductModelAction.Copy:
                    UIPasteboard.general.string = payload.corrAccount
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Deposits.Info.Single.Response:
                    switch payload {
                    case .success(let data):
                        
                        var list: [ItemViewModel] = []
                        
                        let dateFormatter = DateFormatter.detailFormatter
                        
                        list.append(.init(title: "Сумма первоначального размещения", subtitle: data.initialAmount.currencyFormatter(symbol: product.currency)))
                        list.append(.init(title: "Дата открытия", subtitle: dateFormatter.string(from: data.dateOpen)))
                        
                        if let dateEnd = data.dateEnd {
                            
                            list.append(.init(title: "Дата закрытия", subtitle: dateFormatter.string(from: dateEnd)))
                        }
                        
                        if let termDay = data.termDay {
                            
                            list.append(.init(title: "Срок вклада", subtitle: termDay))
                        }
                        
                        list.append(.init(title: "Ставка по вкладу", subtitle: "\(data.interestRate)%"))

                        if let dateNext = data.dateNext {

                            list.append(.init(title: "Дата следующего начисления процентов", subtitle: dateFormatter.string(from: dateNext)))

                        }
                        list.append(.init(title: "Сумма выплаченных процентов всего", subtitle: data.sumPayInt.currencyFormatter(symbol: product.currency)))
                        
                        if let sumCredit = data.sumCredit?.currencyFormatter(symbol: product.currency) {
                            
                            list.append(.init(title: "Суммы пополнений", subtitle: sumCredit))
                        }
                        
                        if let sumDebit = data.sumDebit?.currencyFormatter(symbol: product.currency) {
                            
                            list.append(.init(title: "Суммы списаний", subtitle: sumDebit))
                        }
                        
                        list.append(.init(title: "Сумма начисленных процентов на дату", subtitle: data.sumAccInt.currencyFormatter(symbol: product.currency)))
                        
                        withAnimation {
                            
                            self.list = list
                        }
                        
                    case .failure(let error):
                        self.alert = .init(title: "Ошибка", message: error, primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.alert = nil }))
                    }
                    
                case let payload as ModelAction.Products.ProductDetails.Response:
                    switch payload {
                    case .success(let data):
                        
                        var list: [ItemViewModel] = []
                        
                        list.append(.init(title: "Получатель", subtitle: data.payeeName))
                        list.append(.init(title: "Номер счета", subtitle: data.accountNumber, button: .init(icon: .ic24Copy, action: { [weak self] in
                            self?.action.send(InfoProductModelAction.Copy(corrAccount: data.accountNumber))
                        })))
                        list.append(.init(title: "БИК", subtitle: data.bic))
                        list.append(.init(title: "Корреспондентский счет", subtitle: data.corrAccount))
                        list.append(.init(title: "ИНН", subtitle: data.inn))
                        list.append(.init(title: "КПП", subtitle: data.kpp))
                        
                        withAnimation {
                            
                            self.list = list
                        }
                        
                    case .failure(let error):
                        self.alert = .init(title: "Ошибка", message: error, primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.alert = nil }))
                    }
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
    func setupAdditionalList(for productCardData: ProductCardData) -> [ItemViewModel] {
        
        var additionalList: [ItemViewModel] = []
        
        if let holderName = productCardData.holderName {
            
            additionalList.append(.init(title: "Держатель карты", subtitle: holderName))
        }
        
        if let numberMasked = productCardData.numberMasked {
            
            additionalList.append(.init(title: "Номер карты", subtitle: numberMasked, button: .init(icon: .ic24Eye, action: { [weak self] in
                self?.action.send(InfoProductModelAction.ShowCardNumber(productCardData: productCardData))
            })))
        }
        
        if let expireDate = productCardData.expireDate {
            
            additionalList.append(.init(title: "Карта дейстует до", subtitle: expireDate))
        }
        
        return additionalList
    }
}

struct InfoProductModelAction {
    
    struct ShowCardNumber: Action {
        
        let productCardData: ProductCardData
    }
    
    struct Copy: Action {
        
        let corrAccount: String
    }
}


struct ActivityViewController: UIViewControllerRepresentable {
    
    var itemsToShare: [InfoProductViewModel.ItemViewModel]
    var servicesToShareItem: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        
        var copyText: [Any] = []
        
        for i in itemsToShare {
            copyText.append(i.title + " : " + i.subtitle + "\n")
        }
        
        let controller = UIActivityViewController(activityItems: copyText, applicationActivities: servicesToShareItem)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>){}
}
