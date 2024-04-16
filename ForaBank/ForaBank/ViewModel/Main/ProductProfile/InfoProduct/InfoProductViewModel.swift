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
import Tagged
import PinCodeUI
import CardUI

class InfoProductViewModel: ObservableObject {
    
    typealias ShowCVV = ProductView.ViewModel.ShowCVV

    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var title: String
    @Published var list: [ItemViewModel]
    @Published var listWithAction: [ItemViewModelForList]

    @Published var additionalList: [ItemViewModelForList]?
    @Published var isShareViewPresented = false
    @Published var accountInfoSelected = false
    @Published var cardInfoSelected = false
    @Published var alert: Alert.ViewModel?
    @Published var bottomSheet: BottomSheet?
    @Published var spinner: SpinnerView.ViewModel?
    
    private var needShowNumber = false
    private var needShowCvv = false
    var needShowCheckbox = false {
        didSet {
            if !self.needShowCheckbox {
                self.accountInfoSelected = false
                self.cardInfoSelected = false
            }
        }
    }

    var shareButton: ButtonViewModel?
    var sendAllButtonVM: ButtonModel?
    var sendSelectedButtonVM: ButtonModel?
    
    let product: ProductData
    let showCvv: ShowCVV?

    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(
        product: ProductData,
        title: String,
        list: [ItemViewModel],
        listWithAction: [ItemViewModelForList],
        additionalList: [ItemViewModelForList]?,
        shareButton: ButtonViewModel?,
        model: Model,
        showCvv: ShowCVV? = nil
    ) {
        
        self.product = product
        self.title = title
        self.list = list
        self.listWithAction = listWithAction
        self.additionalList = additionalList
        self.shareButton = shareButton
        self.model = model
        self.showCvv = showCvv
    }
    
    internal init(
        model: Model,
        product: ProductData,
        info: Bool = true,
        showCvv: ShowCVV? = nil
    ) {
        
        self.model = model
        self.product = product
        self.title = ""
        self.list = []
        self.listWithAction = []
        self.showCvv = showCvv
        
        if let cardProductData = product as? ProductCardData {
            
            self.additionalList = self.setupAdditionalList(
                for: cardProductData,
                needShowNumber: needShowNumber,
                needShowCvv: needShowCvv
            )
        }
        
        createShareButtons(isCard: product is ProductCardData)
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
            self.title = "Реквизиты счета и карты"
            
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
            }
        case .loan:
            model.action.send(ModelAction.Products.ProductDetails.Request(type: .loan, id: product.id))
            self.title = "Реквизиты счета"
        }
    }
    
    private func createShareButtons(isCard: Bool) {
        
        //TODO: refactor shareButton logic by removing isShareViewPresented
        self.shareButton = .init(action: { [weak self] in
            
            guard let self = self else { return }
            
            if isCard {
                
                if self.needShowCheckbox {
                    
                    self.isShareViewPresented = true
                } else {
                    
                    self.isShareViewPresented = false
                    self.bottomSheet = .init(type: .share)
                }
            } else { self.isShareViewPresented = true }
        })

        self.sendAllButtonVM = .init(id: .sendAll, action: { [weak self] in
            
            self?.bottomSheet = nil
            self?.isShareViewPresented = true
        })
        
        self.sendSelectedButtonVM = .init(id: .sendSelected, action: { [weak self] in
            
            self?.bottomSheet = nil
            self?.needShowCheckbox = true
        })
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as InfoProductModelAction.ToogleCardNumber:
                    
                    cardNumberToggle(productCardData: payload.productCardData)
                 
                case let payload as InfoProductModelAction.ToogleCVV:
                    
                    cvvToogle(productCardData: payload.productCardData)

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
                        
                        guard data.id == product.id else {
                            return
                        }
                        
                        var list: [ItemViewModel] = []
                        
                        let dateFormatter = DateFormatter.detailFormatter
                        
                        if let initialAmount = model.amountFormatted(amount: data.initialAmount, currencyCode: product.currency, style: .clipped) {
                            
                            list.append(.init(title: "Сумма первоначального размещения", subtitle: initialAmount))
                        }
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
                        if let sumPayInt = model.amountFormatted(amount: data.sumPayInt, currencyCode: product.currency, style: .clipped) {
                            
                            list.append(.init(title: "Сумма выплаченных процентов всего", subtitle: sumPayInt))
                        }
                        
                        if let sumCredit = data.sumCredit, let sumCreditAmount = model.amountFormatted(amount: sumCredit, currencyCode: product.currency, style: .clipped) {
                            
                            list.append(.init(title: "Суммы пополнений", subtitle: sumCreditAmount))
                        }
                        
                        if let sumDebit = data.sumDebit, let sumDebitAmount = model.amountFormatted(amount: sumDebit, currencyCode: product.currency, style: .clipped) {
                            
                            list.append(.init(title: "Суммы списаний", subtitle: sumDebitAmount))
                        }
                        
                        if let sumAccInt = model.amountFormatted(amount: data.sumAccInt, currencyCode: product.currency, style: .clipped) {

                            list.append(.init(title: "Сумма начисленных процентов на дату", subtitle: sumAccInt))
                        }
                        
                        withAnimation {
                            
                            self.list = list
                        }
                        
                    case .failure(let error):
                        self.alert = .init(title: "Ошибка", message: error, primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.alert = nil }))
                    }
                    
                case let payload as ModelAction.Products.ProductDetails.Response:
                    switch payload {
                    case .success(let data):
                        
                        let documentListMultiple = Self.reduceMultiple(data: data)
                        
                        let listMultiple: ItemViewModelForList = Self.makeItemViewModelMultiple(
                            from: documentListMultiple,
                            with: copyValue(value:titleForInformer:)
                        )

                        let documentListSingle = Self.reduceSingle(data: data)
                        
                        var list: [ItemViewModelForList] = documentListSingle.map {
                            
                            Self.makeItemViewModelSingle(
                                from: $0,
                                with: copyValue(value:titleForInformer:)
                            )
                        }
                        list.append(listMultiple)
                        
                        self.listWithAction = list
                        
                    case .failure(let error):
                        self.alert = .init(title: "Ошибка", message: error, primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.alert = nil }))
                    }
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
    func setupAdditionalList(
        for productCardData: ProductCardData,
        needShowNumber: Bool,
        needShowCvv: Bool
    ) -> [ItemViewModelForList] {
        
        let documentListMultiple = Self.reduceMultiple(
            data: productCardData,
            needShowCvv: needShowCvv
        )
        
        let listMultiple: ItemViewModelForList = .multiple(
            documentListMultiple.map {
                
                switch $0.id {
                    
                case .cvv, .cvvMasked:
                    return Self.makeItemViewModel(
                        from: $0,
                        with: {_,_ in },
                        actionForIcon: {
                            
                            self.action.send(InfoProductModelAction.ToogleCVV(productCardData: productCardData))
                        }
                    )
                    
                default:
                    return Self.makeItemViewModel(
                        from: $0,
                        with: copyValue(value:titleForInformer:)
                    )
                }
            }
        )

        let documentListSingle = Self.reduceSingle(
            data: productCardData,
            needShowFullNumber: needShowNumber)
        
        var list: [ItemViewModelForList] = documentListSingle.map {
            
            switch $0.id {
                
            case .number, .numberMasked:
               return Self.makeItemViewModelSingle(
                    from: $0,
                    with: copyValue(value:titleForInformer:),
                    actionForIcon: {
                        
                        self.action.send(InfoProductModelAction.ToogleCardNumber(productCardData: productCardData))
                    }
                )
             
            default:
                return Self.makeItemViewModelSingle(
                    from: $0,
                    with: copyValue(value:titleForInformer:)
                )
            }
        }
        list.append(listMultiple)
        return list
    }
    
    func updateAdditionalList(
        oldList: [ItemViewModelForList]?,
        newCvv: String
    ) -> [ItemViewModelForList]? {
        guard let oldList else { return nil}
        let list = oldList.map { item in
            switch item {
            case .single:
                return item
            case let .multiple(items):
              let newItems = items.map {
                  switch $0.id {
                      
                  case .cvv:
                      var newItem = $0
                      newItem.subtitle = newCvv
                      return newItem
                      
                  default:
                      return $0
                  }
                }
                return .multiple(newItems)
            }
        }
        return list
    }
    
    func copyValue(value: String, titleForInformer: String) {
        
        UIPasteboard.general.string = value
        self.model.action.send(ModelAction.Informer.Show(
            informer: .init(
                message: "\(titleForInformer) скопирован",
                icon: .copy,
                type: .copyInfo
            )
        ))
    }
    
    func hideCheckBox() {
        
        self.needShowCheckbox = false
    }
    
    struct BottomSheet: Identifiable, BottomSheetCustomizable {

        let id = UUID()
        let type: BottomSheetType
        
        enum BottomSheetType {

            case share
        }
    }
}

struct InfoProductModelAction {
    
    struct ToogleCardNumber: Action {
        
        let productCardData: ProductCardData
    }
    
    struct ToogleCVV: Action {
        
        let productCardData: ProductCardData
    }
    
    struct ShowCVV: Action {
        let cardId: CardDomain.CardId
        let cvv: CardInfo.CVV
    }
    
    enum Spinner {
        
        struct Show: Action {}
        struct Hide: Action {}
    }
    
    struct Close: Action {}
}

extension InfoProductViewModel {
    
    var isDisableShareButton: Bool {
        
       return needShowCheckbox ? !(accountInfoSelected || cardInfoSelected) : false
    }

    var dataForShare: [Any] {
        
        var data: [Any] = []
        
        if !list.isEmpty {
            
            data.append(list)
        }

        if needShowCheckbox {
            
            if accountInfoSelected {
                
                data.append(listWithAction)
            }
            if cardInfoSelected, let additionalList = additionalList {
                
                data.append(additionalList)
            }
        } else {

            data.append(listWithAction)
            if let additionalList = additionalList {
                
                data.append(additionalList)
            }
        }
        return data
    }
}

extension InfoProductViewModel {
    
    func cardNumberToggle(productCardData: ProductCardData) {
        
        needShowNumber.toggle()
        
        if needShowNumber, needShowCvv {
            
            needShowCvv.toggle()
        }
        self.additionalList = self.setupAdditionalList(
            for: productCardData,
            needShowNumber: needShowNumber,
            needShowCvv: needShowCvv
        )
    }
    
    func cvvToogle(productCardData: ProductCardData) {
        
        needShowCvv.toggle()
        
        if self.needShowNumber, self.needShowCvv {
            
            self.needShowNumber.toggle()
        }

        self.additionalList = self.setupAdditionalList(
            for: productCardData,
            needShowNumber: needShowNumber,
            needShowCvv: needShowCvv
        )
        
        if needShowCvv {
            self.showCvv?(.init(productCardData.id)) { [weak self] in
                guard let self else { return }
                
                if let cvv = $0 {
                    self.additionalList = self.updateAdditionalList(
                        oldList: self.additionalList,
                        newCvv: cvv.rawValue
                    )
                }
            }
        }
    }
    
    func itemsToString(items: [Any]) -> String {
        
        var allValues: String = ""
        
        for item in items {
            
            if let list = item as? [InfoProductViewModel.ItemViewModel] {
                
                let copyTextString: String = list.map {
                    
                    return $0.title + " : " + $0.subtitle
                }.joined(separator: "\n")
                
                
                allValues = copyTextString + "\n\n"
            }
            else if let listNew = item as? [InfoProductViewModel.ItemViewModelForList] {
                
                let copyTextString: String = listNew.map {
                    
                    $0.currentValueString
                }.joined(separator: "\n")
                
                allValues = allValues + "\n\n" + copyTextString
            }
        }
        return allValues
    }
}

extension InfoProductViewModel {
    
    func close() {
        self.action.send(InfoProductModelAction.Close())
    }
}
