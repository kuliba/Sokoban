//
//  SbpPayViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 29.08.2022.
//

import Foundation
import SwiftUI
import Combine

class SbpPayViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let header: HeaderViewModel
    let paymentProduct: ProductSelectorView.ViewModel?
    let conditions: [ConditionViewModel]
    @Published var footer: FooterViewModel
    var rootActions: RootViewModel.RootActions?

    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    struct HeaderViewModel {
        
        let title = "Подключение счета к СБПэй"
        let image: Image = Image.ic40SBP
    }
    
    struct FooterViewModel {
        
        let descriptionButton = #"Нажимая кнопку "Подключить", вы соглашаетесь с условиями обслуживания Банка и СБПэй"#
        let spinnerIcon: Image = .init("Logo Fora Bank")
        let state: State
        
        enum State {
            
            case button(ButtonSimpleView.ViewModel)
            case spinner
        }
    }
    
    struct ConditionViewModel: Hashable {
        
        let image: Image = .ic24FileText
        let title: String
        let link: URL
        
        static func == (lhs: ConditionViewModel, rhs: ConditionViewModel) -> Bool {
            return lhs.image == rhs.image && lhs.title == rhs.title
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }
    }
    
    internal init(_ model: Model, paymentProduct: ProductSelectorView.ViewModel?, conditions: [SbpPayViewModel.ConditionViewModel], rootActions: RootViewModel.RootActions?) {
        
        self.model = model
        self.header = .init()
        self.paymentProduct = paymentProduct
        self.conditions = conditions
        self.rootActions = rootActions
        
        self.footer = .init(state: .button(.init(title: "Подключить", style: .red, action: {})))
        
        bind()
    }
    
    convenience init(_ model: Model, personAgreements: [PersonAgreement], rootActions: RootViewModel.RootActions?) {
        
        let paymentProduct = Self.makeProductCardSelector(model: model)
        let personAgreements: [ConditionViewModel] = Self.personAgreements(personAgreements)
            
        self.init(model, paymentProduct: paymentProduct, conditions: personAgreements, rootActions: rootActions)
        
        self.footer = .init(state: .button(.init(title: "Подключить", style: .red, action: { [weak self] in
            
            self?.footer = .init(state: .spinner)
            
            guard let product = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == paymentProduct?.productViewModel?.productId }) else {
                return
            }
            
            if let product = product as? ProductCardData, let accountId = product.accountId?.description {
                
                self?.model.action.send(ModelAction.SbpPay.ProcessTokenIntent.Request(accountId: accountId, status: .success))
                
            } else if let accountId = paymentProduct?.productViewModel?.productId.description {
                
                self?.model.action.send(ModelAction.SbpPay.ProcessTokenIntent.Request(accountId: accountId, status: .success))
            }
        })))
    }
    
    private func bind() {

        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.SbpPay.ProcessTokenIntent.Response:
                    
                    rootActions?.dismissAll()
                    switch model.deepLinkType.value {
                        
                    case let .sbpPay(tokenIntentId):
                        
                        guard let url = URL(string: "sbpay://tokenIntent/\(tokenIntentId)/\(payload.result)") else {
                            return
                        }
                       
                        guard UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        
                        model.deepLinkType.value = nil
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    default: break
                    }
                    
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
    static func personAgreements(_ personAgreement: [PersonAgreement]) -> [ConditionViewModel] {
        
        var conditionViewModel: [ConditionViewModel] = []
        
        for agreement in personAgreement {
            
            conditionViewModel.append(.init(title: agreement.comment, link: agreement.externalUrl))
        }
        
        return conditionViewModel
    }
    
    static func makeProductCardSelector(model: Model) -> ProductSelectorView.ViewModel? {
        
        let title = "Счет списания"
        let products = model.products(currency: .rub).filter({$0.productType == .account || $0.productType == .card})
        
        guard let productData = products.first else {
            return nil
        }
        
        if let accountId = model.fastPaymentContractFullInfo.value.first?.fastPaymentContractAccountAttributeList?.first?.accountId {
         
            if let product = products.filter({($0 as? ProductCardData)?.accountId == accountId}).first {
                
                let selectorViewModel: ProductSelectorView.ViewModel = .init(model, title: title, currency: .rub, currencyOperation: .buy, productViewModel: .init(productId: product.id, productData: product, model: model), isDividerHiddable: true, backgroundColor: .white, titleIndent: .left, context: .init(isAdditionalProducts: false))
                return selectorViewModel
                
            } else if let product = products.filter({$0.id == accountId}).first {
                
                let selectorViewModel: ProductSelectorView.ViewModel = .init(model, title: title, currency: .rub, currencyOperation: .buy, productViewModel: .init(productId: product.id, productData: product, model: model), isDividerHiddable: true, backgroundColor: .white, titleIndent: .left, context: .init(isAdditionalProducts: false))
                return selectorViewModel
            }
        }
        
        let selectorViewModel: ProductSelectorView.ViewModel = .init(model, title: title, currency: .rub, currencyOperation: .buy, productViewModel: .init(productId: productData.id, productData: productData, model: model), isDividerHiddable: true, backgroundColor: .white, titleIndent: .left, context: .init(isAdditionalProducts: false))
        return selectorViewModel
    }
}
