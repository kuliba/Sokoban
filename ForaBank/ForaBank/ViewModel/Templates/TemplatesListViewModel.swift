//
//  TemplatesListViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 18.01.2022.
//

import Foundation
import SwiftUI
import Combine

class TemplatesListViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var state: State
    @Published var style: Style
    @Published var title: String
    @Published var navButtonsRight: [NavigationBarButtonViewModel]
    @Published var categorySelector: OptionSelectorView.ViewModel?
    @Published var items: [ItemViewModel]
    @Published var onboarding: OnboardingViewModel?
    @Published var contextMenu: ContextMenuViewModel?
    @Published var deletePannel: DeletePannelViewModel?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    private let selectedItemsIds: CurrentValueSubject<Set<ItemViewModel.ID>, Never> = .init([])
    private let itemsRaw: CurrentValueSubject<[ItemViewModel], Never> = .init([])
    private let categoryIndexAll = "TemplatesListViewModelCategoryAll"
    
    init(_ model: Model) {
        
        self.state = .normal
        self.style = model.paymentTemplatesViewSettings.value.style
        self.title = "Шаблоны"
        self.navButtonsRight = []
        self.items = []
        self.model = model
        self.model.action.send(ModelAction.PaymentTemplate.List.Requested())
        
        bind()
    }
    
    internal init(state: State, style: Style, title: String, navButtonsRight: [NavigationBarButtonViewModel], categorySelector: OptionSelectorView.ViewModel, items: [ItemViewModel], contextMenu: ContextMenuViewModel?, deletePannel: DeletePannelViewModel?, model: Model) {
        
        self.state = state
        self.style = style
        self.title = title
        self.navButtonsRight = navButtonsRight
        self.categorySelector = categorySelector
        self.items = items
        self.contextMenu = contextMenu
        self.deletePannel = deletePannel
        self.model = model
    }
    
    func closeContextMenu() {
        
        contextMenu = nil
    }
}

//MARK: - Bindings

private extension TemplatesListViewModel {
    
    func bind() {
        
        // templates data updates from model
        model.paymentTemplates
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] templates in
                
                withAnimation {
                    
                    style = model.paymentTemplatesViewSettings.value.style
                    
                    if templates.isEmpty == false {
                        
                        state = .normal
                        itemsRaw.value = templates.compactMap{ itemViewModel(with: $0) }
                        categorySelector = categorySelectorViewModel(with: templates)
                        bindCategorySelector()
                        navButtonsRight = [menuButtonViewModel()]
                        onboarding = nil
                        
                    } else {
                        
                        state = .onboarding
                        itemsRaw.value = []
                        categorySelector = nil
                        navButtonsRight = []
                        onboarding = onboardingViewModel()
                    }
                }
    
            }.store(in: &bindings)
        
        // all templates view models storage updates
        itemsRaw
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] itemsRaw in
                
                withAnimation {
                    
                    if let selectedCategoryIndex = categorySelector?.selected {
                        
                        items = sortedItems(filterredItems(itemsRaw, selectedCategoryIndex))
                        
                    } else {
                        
                        items = sortedItems(itemsRaw)
                    }
                    
                    updateAddNewTemplateItem()
                }
 
            }.store(in: &bindings)
        
        // actions handlers
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as TemplatesListViewModelAction.ItemTapped:
                    guard let temp = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == payload.itemId}) else { return }
                    switch temp.type {
                        
                    case .otherBank:
                        print("Скорее всего не будет сделано в ближайшее время")
                        
                    case .betweenTheir:
                        self.action.send(TemplatesListViewModelAction.Present.PaymentToMyCard(viewModel: temp))
                        
                    case .insideBank:
                        self.action.send(TemplatesListViewModelAction.Present.PaymentInsideBankByCard(viewModel: temp))
                        
                    case .byPhone:
                        let paymentViewModel = PaymentByPhoneViewModel(insideByPhone: temp)
                        self.action.send(TemplatesListViewModelAction.Present.PaymentInsideBankByPhone(viewModel: paymentViewModel))
                        
                    case .sfp:
                        let paymentViewModel = PaymentByPhoneViewModel(spf: temp)
                        self.action.send(TemplatesListViewModelAction.Present.PaymentSFP(viewModel: paymentViewModel))
                        
                    case .direct:
                        self.action.send(TemplatesListViewModelAction.Present.PaymentMig(viewModel: temp))
                        
                    case .contactAdressless:
                        self.action.send(TemplatesListViewModelAction.Present.PaymentContact(viewModel: temp))
                        
                    case .housingAndCommunalService:
                        self.action.send(TemplatesListViewModelAction.Present.GKHPayment(viewModel: temp))
                        
                    case .mobile:
                        self.action.send(TemplatesListViewModelAction.Present.MobilePayment(viewModel: temp))
                        
                    case .internet:
                        self.action.send(TemplatesListViewModelAction.Present.InterneetPayment(viewModel: temp))
                        
                    case .transport:
                        self.action.send(TemplatesListViewModelAction.Present.TransportPayment(viewModel: temp))
                        
                    case .externalEntity:
                        self.action.send(TemplatesListViewModelAction.Present.OrgPaymentRequisites(viewModel: temp))
                        
                    case .externalIndividual:
                        self.action.send(TemplatesListViewModelAction.Present.PaymentRequisites(viewModel: temp))
                        
                    default:
                        break
                    }
                    
                case _ as TemplatesListViewModelAction.ToggleStyle:
                    
                    withAnimation {
                        
                        for item in itemsRaw.value {
                            
                            item.state = .normal
                        }
                        
                        switch style {
                        case .list: style = .tiles
                        case .tiles: style = .list
                        }
                    }
                    
                case _ as TemplatesListViewModelAction.Delete.Selection.Enter:
                    
                    withAnimation {
                        
                        state = .select
                        navButtonsRight = [cancelDeleteModeButtonViewModel()]
                        selectedItemsIds.value = []
                        deletePannel = deletePannelViewModel(selectedCount: 0)
                        
                        for item in itemsRaw.value {
                            
                            item.state = .select(.init(isSelected: false, action: {[weak self] itemId in
                                
                                self?.action.send(TemplatesListViewModelAction.Delete.Selection.ToggleItem(itemId: itemId))
                                
                            }))
                        }
                    }

                case _ as TemplatesListViewModelAction.Delete.Selection.Exit:
                    
                    withAnimation {
                        
                        state = .normal
                        navButtonsRight = [menuButtonViewModel()]
                        selectedItemsIds.value = []
                        deletePannel = nil
                        
                        for item in itemsRaw.value {
                            
                            item.state = .normal
                        }
                    }

                case let payload as TemplatesListViewModelAction.Delete.Selection.ToggleItem:
                    guard let item = itemsRaw.value.first(where: { $0.id == payload.itemId}) else {
                        return
                    }
                    let action: (ItemViewModel.ID) -> Void = {[weak self] itemId in
                        
                        self?.action.send(TemplatesListViewModelAction.Delete.Selection.ToggleItem(itemId: itemId))
                    }
                    
                    withAnimation {
                        
                        if selectedItemsIds.value.contains(item.id) {
                            
                            selectedItemsIds.value.remove(item.id)
                            item.state = .select(.init(isSelected: false, action: action))
                            
                        } else {
                            
                            selectedItemsIds.value.insert(item.id)
                            item.state = .select(.init(isSelected: true, action: action))
                        }
                    }
                    
                case _ as TemplatesListViewModelAction.Delete.Selection.Accept:
                    model.action.send(ModelAction.PaymentTemplate.Delete.Requested(paymentTemplateIdList: Array(selectedItemsIds.value)))
                    self.action.send(TemplatesListViewModelAction.Delete.Selection.Exit())
                    
                case let payload as TemplatesListViewModelAction.Delete.Item:
                    model.action.send(ModelAction.PaymentTemplate.Delete.Requested(paymentTemplateIdList: [payload.itemId]))
                    
                    withAnimation {
                        
                        for item in itemsRaw.value {
                            
                            item.state = .normal
                        }
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
        
        // selected items updates
        selectedItemsIds
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] selected in
                
                if state == .select {
                    
                    deletePannel = deletePannelViewModel(selectedCount: selected.count)
                }
                
            }.store(in: &bindings)
        
        // state changes
        $state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                withAnimation {
                    
                    updateTitle()
                    updateAddNewTemplateItem()
                }
                
            }.store(in: &bindings)
        
        $style
            .sink { [unowned self] style in
                
                model.paymentTemplatesViewSettings.value = Settings(style: style)
                
            }.store(in: &bindings)
            
    }
    
    func bindCategorySelector() {
        
        categorySelector?.$selected
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self]  selectedCategoryIndex in
                
                items = sortedItems(filterredItems(itemsRaw.value, selectedCategoryIndex))
                updateAddNewTemplateItem()
                
            }.store(in: &bindings)
    }
}

//MARK: - Settings

extension TemplatesListViewModel {
    
    struct Settings: Cachable {
        
        let style: Style
        
        static let initial = Settings(style: .list)
    }
}

//MARK: - Template Items View Models

private extension TemplatesListViewModel {
    
    func itemViewModel(with template: PaymentTemplateData) -> ItemViewModel? {
        
        guard let amount = amount(for: template) else {
            return nil
        }
        
        let image = image(for: template)
        let subTitle = subTitle(for: template)
        let logoImage = logoImage(for: template)
        
        return ItemViewModel(id: template.paymentTemplateId,
                             sortOrder: template.sort,
                             state: .normal,
                             image: image,
                             title: template.name,
                             subTitle: subTitle,
                             logoImage: logoImage,
                             ammount: amount,
                             tapAction: { [weak self] itemId in  self?.action.send(TemplatesListViewModelAction.ItemTapped(itemId: itemId)) },
                             deleteAction: { [weak self] itemId in  self?.action.send(TemplatesListViewModelAction.Delete.Item(itemId: itemId))})
    }
    
    func itemAddNewTemplateViewModel() -> ItemViewModel {
        
        return ItemViewModel(id: Int.max,
                             sortOrder: Int.max,
                             state: .normal,
                             image: Image("Templates Add New Icon"),
                             title: "Добавить шаблон",
                             subTitle: "Из операции в разделе История",
                             logoImage: nil,
                             ammount: "",
                             tapAction: { [weak self] _ in  self?.action.send(TemplatesListViewModelAction.AddTemplate()) },
                             deleteAction: { _ in }, kind: .add)
    }
    
    func image(for template: PaymentTemplateData) -> Image {
        
        //TODO: placeholder
        template.svgImage.image ?? Image("")
    }
    
    func subTitle(for template: PaymentTemplateData) -> String {
        
        template.groupName
    }
    
    func logoImage(for template: PaymentTemplateData) -> Image? {
        
        return nil
    }
    
    func amount(for template: PaymentTemplateData) -> String? {
        
        if template.type == .contactAdressless ,
           let parameterList = template.parameterList.first as? TransferAnywayData,
           let currencyAmount = parameterList.additional.first(where: { $0.fieldname == "CURR" }),
           let amount = template.amount {
            
            
            return amount.currencyFormatter(symbol: currencyAmount.fieldvalue)
            
        } else {
            
            if template.parameterList.count > 1 {
                var amount: Double?
                var currencyAmount: String?
                
                template.parameterList.forEach { parameter in
                    if let paramAmount = parameter.amount {
                        amount = paramAmount
                    }
                    currencyAmount = parameter.currencyAmount
                    
                }
                if let amount = amount,
                   let currencyAmount = currencyAmount {
                    
                    return amount.currencyFormatter(symbol: currencyAmount)
                    
                } else {
                    
                    return nil
                }
                
            } else {
                guard let transfer = template.parameterList.first,
                      let amount = template.amount else {
        
                    return nil
                }
                return amount.currencyFormatter(symbol: transfer.currencyAmount)
            }
            
        }
    }
}

//MARK: - Filtering & Sorting

private extension TemplatesListViewModel {
    
    func filterredItems(_ items: [ItemViewModel], _ selectedCategoryIndex: String) -> [ItemViewModel] {
        
        if selectedCategoryIndex == categoryIndexAll {
            
            return items
            
        } else {
            
            return items.filter{ $0.subTitle == selectedCategoryIndex }
        }
    }
    
    func sortedItems(_ items: [ItemViewModel]) -> [ItemViewModel] {
        
        return items.sorted(by: { $0.sortOrder < $1.sortOrder })
    }
}

//MARK: - Navigation Buttons View Models

private extension TemplatesListViewModel {
    
    func menuButtonViewModel() -> NavigationBarButtonViewModel {
        
        NavigationBarButtonViewModel(icon: Image("more-horizontal")) { [weak self] in
            
            guard let self = self else {
                return
            }
            
            if self.contextMenu == nil {
                
                self.contextMenu = self.contextMenuViewModel()
                
            } else {
                
                self.contextMenu = nil
            }
        }
    }
    
    func cancelDeleteModeButtonViewModel() -> NavigationBarButtonViewModel {
        
        NavigationBarButtonViewModel(icon: Image("Templates Nav Icon Cancel"), action: {[weak self] in self?.action.send(TemplatesListViewModelAction.Delete.Selection.Exit()) })
    }
}

//MARK: - Local View Models

private extension TemplatesListViewModel {
    
    func categorySelectorViewModel(with templates: [PaymentTemplateData]) -> OptionSelectorView.ViewModel {
        
        let groupNames = templates.map{ $0.groupName }
        let groupNamesUnique = Set(groupNames)
        let groupNamesSorted = Array(groupNamesUnique).sorted(by: { $0 < $1 })
        var options = groupNamesSorted.map{ Option(id: $0, name: $0) }
        let optionAll = Option(id: categoryIndexAll, name: "Все")
        options.insert(optionAll, at: 0)
        
        return OptionSelectorView.ViewModel(options: options, selected: optionAll.id, style: .template, horizontalPadding: 20)
    }
    
    func isCategorySelectorContainsCategory(categoryId: Option.ID) -> Bool {
        
        guard let categorySelector = categorySelector else {
            return false
        }
        
        let categoriesIds = categorySelector.options.map{ $0.id }
        
        return categoriesIds.contains(categoryId)
    }
    
    func contextMenuViewModel() -> ContextMenuViewModel {
        
        var menuItems = [ContextMenuViewModel.MenuItemViewModel]()
        
        //TODO: implement sorting first
        /*
        let orderMenuItem = ContextMenuViewModel.MenuItemViewModel(icon: Image("bar-in-order"), title: "Последовательность") { [weak self] in
            //TODO: action required
            self?.closeContextMenu()
        }
        menuItems.append(orderMenuItem)
         */
        
        if #available(iOS 14, *) {
            switch style {
            case .list:
                let styleMenuItem = ContextMenuViewModel.MenuItemViewModel(icon: Image("grid"), title: "Вид (Плитка)") { [weak self] in
                    self?.action.send(TemplatesListViewModelAction.ToggleStyle())
                    self?.closeContextMenu()
                }
                menuItems.append(styleMenuItem)
                
            case .tiles:
                let styleMenuItem = ContextMenuViewModel.MenuItemViewModel(icon: Image("Templates Menu Icon List"), title: "Вид (Список)") { [weak self] in
                    self?.action.send(TemplatesListViewModelAction.ToggleStyle())
                    self?.closeContextMenu()
                }
                menuItems.append(styleMenuItem)
            }
        }
        
        let deleteMenuItem = ContextMenuViewModel.MenuItemViewModel(icon: Image("trash_empty"), title: "Удалить") { [weak self] in
            self?.action.send(TemplatesListViewModelAction.Delete.Selection.Enter())
            self?.closeContextMenu()
        }
        menuItems.append(deleteMenuItem)
        
        return ContextMenuViewModel(items: menuItems)
    }
    
    func deletePannelViewModel(selectedCount: Int) -> DeletePannelViewModel {
        
        DeletePannelViewModel(description: "Выбрано \(selectedCount)",
                              button: .init(icon: Image("trash"), caption: "Удалить все", isEnabled: selectedCount > 0, action: {[weak self] in self?.action.send(TemplatesListViewModelAction.Delete.Selection.Accept()) }))
    }
    
    func onboardingViewModel() -> OnboardingViewModel {
        
        OnboardingViewModel(icon: Image("Templates Onboarding Icon"),
                            title: "Нет шаблонов", message: "Вы можете создать шаблон из любой успешной операции в разделе История",
                            button: .init(title: "Перейти в историю",
                                          action: { [weak self] in self?.action.send(TemplatesListViewModelAction.AddTemplate())}))
    }
}


//MARK: - Updates

private extension TemplatesListViewModel {
    
    func updateAddNewTemplateItem() {
        
        switch state {
        case .normal:
            guard let lastItem = items.last, lastItem.kind != .add else {
                return
            }

            items.append(itemAddNewTemplateViewModel())
            
        default:
            guard let lastItem = items.last, lastItem.kind == .add else {
                return
            }
            
            items.removeLast()
        }
    }
    
    func updateTitle() {
        
        switch state {
        case .onboarding, .normal:
            title = "Шаблоны"
            
        case .select:
            title = "Выбрать объекты"
        }
    }
}

//MARK: - External Components

struct NavigationBarButtonViewModel: Identifiable {
    
    let id: String = UUID().uuidString
    let icon: Image
    let action: () -> Void
}

//MARK: - Internal Components

extension TemplatesListViewModel {
    
    enum State {
        
        case onboarding
        case normal
        case select
    }
    
    enum Style: Codable {
        
        case list
        case tiles
    }
    
    struct NewTemplateButtonModel {
        
        let image: Image
        let title: String
        let subTitle: String
        let action: () -> Void
    }

    class DeletePannelViewModel: ObservableObject {

        @Published var description: String
        let button: ButtonViewModel
        
        struct ButtonViewModel {
            
            let icon: Image
            let caption: String
            let isEnabled: Bool
            let action: () -> Void
        }
        
        internal init(description: String, button: ButtonViewModel) {
            
            self.description = description
            self.button = button
        }
    }
    
    struct OnboardingViewModel {
        
        let icon: Image
        let title: String
        let message: String
        let button: ButtonViewModel
        
        struct ButtonViewModel {
            
            let title: String
            let action: () -> Void
        }
    }
}

//MARK: - ItemViewModel

extension TemplatesListViewModel {
    
    class ItemViewModel: Identifiable, ObservableObject {

        let id: Int
        let sortOrder: Int
        @Published var state: State
        let image: Image
        let title: String
        @Published var subTitle: String
        let logoImage: Image?
        let ammount: String
        let tapAction: (ItemViewModel.ID) -> Void
        let deleteAction: (ItemViewModel.ID) -> Void
        let kind: Kind //FIXME: kind looks ugly, refactor it to subclasses
        lazy var swipeLeft: () -> Void = {

            switch self.state {
            case .normal:
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.state = .delete(.init(icon: Image("trash_empty"), subTitle: "Удалить", action: self.deleteAction))
                }
                
            default:
                break
            }
        }
        
        lazy var swipeRight: () -> Void = {

            switch self.state {
            case .delete:
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.state = .normal
                }
                
            default:
                break
            }
        }

        internal init(id: Int, sortOrder: Int, state: TemplatesListViewModel.ItemViewModel.State, image: Image, title: String, subTitle: String, logoImage: Image?, ammount: String, tapAction: @escaping (ItemViewModel.ID) -> Void, deleteAction: @escaping (ItemViewModel.ID) -> Void, kind: Kind = .regular) {
            
            self.id = id
            self.sortOrder = sortOrder
            self.state = state
            self.image = image
            self.title = title
            self.subTitle = subTitle
            self.logoImage = logoImage
            self.ammount = ammount
            self.tapAction = tapAction
            self.deleteAction = deleteAction
            self.kind = kind
        }
        
        enum State {
            
            case normal
            case select(ToggleRoundButtonViewModel)
            case delete(DeleteButtonViewModel)
            case deleting(DeletingProgressViewModel)
        }
        
        struct ToggleRoundButtonViewModel {
            
            let isSelected: Bool
            let action: (ItemViewModel.ID) -> Void
        }
        
        struct DeleteButtonViewModel {
            
            let icon: Image
            let subTitle: String
            let action: (ItemViewModel.ID) -> Void
        }
        
        struct DeletingProgressViewModel {
            
            let progress: Double
            let countTitle: String
            let cancelButton: CancelButtonViewModel
        }
        
        struct CancelButtonViewModel {
            
            let title: String
            let action: (ItemViewModel.ID) -> Void
        }
        
        enum Kind {
            
            case regular
            case add
        }
    }
}
