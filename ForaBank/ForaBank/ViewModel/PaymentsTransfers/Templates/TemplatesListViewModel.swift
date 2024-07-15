//
//  TemplatesListViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 18.01.2022.
//

import Combine
import CombineSchedulers
import Foundation
import SwiftUI

class TemplatesListViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var state: State
    @Published var style: Style
    @Published var navBarState: NavBarState
    @Published var editModeState: EditMode = .inactive
    @Published var idList: UUID = UUID()
    
    @Published var categorySelector: OptionSelectorView.ViewModel?
    @Published var deletePanel: DeletePannelViewModel?
    
    @Published var items: [ItemViewModel]

    @Published var route: Route { didSet { isLinkActive = route.link != nil }}
    @Published var success: PaymentsSuccessViewModel?
    @Published var isLinkActive: Bool = false
    
    private let model: Model
    var bindings = Set<AnyCancellable>()
    
    private let selectedItemsIds: CurrentValueSubject<Set<ItemViewModel.ID>, Never> = .init([])
    private let itemsRaw: CurrentValueSubject<[ItemViewModel], Never> = .init([])
    private let categoryIndexAll = "TemplatesListViewModelCategoryAll"
    
    let dismissAction: () -> Void
    private let updateFastAll: UpdateFastAll
    
    var isDeleteProcessing: Bool { !items.filter{$0.state.isDeleteProcessing}.isEmpty }
    var isExistDeleted: Bool { !items.filter{$0.state.isDeleting}.isEmpty }
    
    private let flowManager: TemplatesFlowManager
    private let routeSubject = PassthroughSubject<Route, Never>()
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    internal init(
        route: Route = .init(),
        state: State,
        style: Style,
        navBarState: NavBarState,
        categorySelector: OptionSelectorView.ViewModel?,
        items: [ItemViewModel],
        deletePannel: DeletePannelViewModel?,
        dismissAction: @escaping () -> Void = {},
        updateFastAll: @escaping UpdateFastAll,
        model: Model,
        flowManager: TemplatesFlowManager,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.route = route
        self.state = state
        self.style = style
        self.navBarState = navBarState
        self.categorySelector = categorySelector
        self.items = items
        self.deletePanel = deletePannel
        self.dismissAction = dismissAction
        self.updateFastAll = updateFastAll
        self.model = model
        self.flowManager = flowManager
        self.scheduler = scheduler
        
        routeSubject
            .receive(on: scheduler)
            .assign(to: &$route)
    }
    
    convenience init(
        route: Route = .init(),
        _ model: Model,
        dismissAction: @escaping () -> Void,
        updateFastAll: @escaping UpdateFastAll,
        flowManager: TemplatesFlowManager,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        model.action.send(ModelAction.PaymentTemplate.List.Requested())
        
        self.init(
            route: route,
            state: model.paymentTemplates.value.isEmpty ? .placeholder : .normal,
            style: model.settingsPaymentTemplates.style,
            navBarState: .regular(
                .init(
                    backButton: .init(
                        icon: .ic24ChevronLeft,
                        action: dismissAction),
                    menuList: [],
                    searchButton: .init(
                        icon: .ic24Search,
                        action: {}
                    )
                )
            ),
            categorySelector: nil,
            items: [],
            deletePannel: nil,
            dismissAction: dismissAction,
            updateFastAll: updateFastAll,
            model: model,
            flowManager: flowManager,
            scheduler: scheduler
        )
        
        updateNavBar(event: .setRegular)
        bind()
    }
    
    deinit {
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "TemplatesListViewModel deinitialized")
    }
}

//MARK: - Bindings
private extension TemplatesListViewModel {
    
    func bind() {
        
        model.action
            .receive(on: scheduler)
            .sink { [unowned self] action in

                switch action {
                    
                case _ as ModelAction.PaymentTemplate.List.Failed:
                    
                    model.action.send(ModelAction.Informer.Show
                        .init(informer: .init(message: "Не удалось загрузить шаблоны",
                                              icon: .close)))
                    
                case let payload as ModelAction.PaymentTemplate.Update.Failed:
                    
                    model.action.send(ModelAction.Informer.Show
                        .init(informer: .init(message: "Не удалось сохранить изменения",
                                              icon: .close)))
                    guard let item = items.first(where: { $0.id == payload.paymentTemplateId})
                    else { return }
                    
                    item.state = .normal
                    self.idList = UUID()
                    
                case let payload as ModelAction.PaymentTemplate.Update.Complete:
                    
                    guard let item = items.first(where: { $0.id == payload.paymentTemplateId})
                    else { return }
                    
                    item.state = .normal
                    item.title = payload.newName
                    self.idList = UUID()
                
                case _ as ModelAction.PaymentTemplate.Delete.Failed:
                    
                    model.action.send(ModelAction.Informer.Show
                        .init(informer: .init(message: "Не удалось удалить шаблоны",
                                              icon: .close)))
                    withAnimation {
                        
                        self.items = reduceItems(rawItems: self.itemsRaw.value,
                                                 isDataUpdating: false,
                                                 categorySelected: self.categorySelector?.selected,
                                                 searchText: self.navBarState.searchModel?.searchText,
                                                 isAddItemNeeded: true)
                    }
                
                case _ as ModelAction.PaymentTemplate.Delete.Complete:
                    
                    if !self.isDeleteProcessing, self.isExistDeleted  {
                        model.action.send(ModelAction.PaymentTemplate.List.Requested())
                    }
                    
                case _ as ModelAction.PaymentTemplate.Sort.Failed:
                    
                    model.action.send(ModelAction.Informer.Show
                        .init(informer: .init(message: "Не удалось сохранить изменения",
                                              icon: .close)))
                    
                    self.action.send(TemplatesListViewModelAction.ReorderItems.CloseEditMode())
                    
                default: break
                }
            }.store(in: &bindings)
        
    
        model.paymentTemplates
            .receive(on: scheduler)
            .sink { [unowned self] templates in
                    
                if templates.isEmpty {
                   
                    withAnimation {
                        
                        state = .emptyList(getEmptyTemplateListViewModel())
                        itemsRaw.value = []
                        categorySelector = nil
                    }
                        
                } else {
                    
                    let templatesVM = templates.compactMap { getItemViewModel(with: $0, model: model) }
                       
                    let selector = self.categorySelector?.selected
                        
                    withAnimation {
                        
                        self.state = .normal
                        self.itemsRaw.value = templatesVM
                        let newCategorySelector = getCategorySelectorModel(with: templates)
                        bindCategorySelector(newCategorySelector)
                        if let selector,
                           newCategorySelector.options.contains(where: { $0.id == selector }) {
                            
                            newCategorySelector.selected = selector
                        }
                        self.categorySelector = newCategorySelector
                    }
                    
                }
            }.store(in: &bindings)
        
        model.images
            .receive(on: scheduler)
            .sink { [unowned self] images in
                
                itemsRaw.value.filter { $0.avatar.isPlaceholder }
                     .forEach { item in
                    
                         if let img = images["Template\(item.id)"]?.image {
                             item.avatar = .image(img)
                         }
                }
                
                withAnimation {
                 
                    self.items = reduceItems(rawItems: self.itemsRaw.value,
                                             isDataUpdating: false,
                                             categorySelected: self.categorySelector?.selected,
                                             searchText: self.navBarState.searchModel?.searchText,
                                             isAddItemNeeded: !self.state.isSelect)
                }
                
        }.store(in: &bindings)
        
        $items
            .receive(on: scheduler)
            .sink { [unowned self] items in
                
                switch navBarState {
                case let .regular(viewModel):
                    
                    if items.contains(where: { $0.kind == .deleting || $0.kind == .placeholder })
                        || items.filter({ $0.kind == .regular }).isEmpty
                        || state.isPlaceholder {
                        
                        viewModel.isMenuDisable = true
                        viewModel.isSearchButtonDisable = true
                        
                    } else {
                        
                        viewModel.isMenuDisable = false
                        viewModel.isSearchButtonDisable = false
                    }
                    
                default: break
                }
                
            }.store(in: &bindings)
        
    // actions handlers
        action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                    
            //Add Item Tapped
                case _ as TemplatesListViewModelAction.AddTemplateTapped:
                    
                    let productsFilterred = model.products.value.filter { dict in
                        dict.key == .card || dict.key == .account
                    }
                    let sectionSettings = ProductsSectionsSettings(collapsed: ["CARD": true, "ACCOUNT": true] )
                    
                    let productSections = MyProductsViewModel
                                            .updateViewModel(with: productsFilterred,
                                                             sections: [],
                                                             productsOpening: [],
                                                             settingsProductsSections: sectionSettings,
                                                             model: model)
                   
                    let productListViewModel = ProductListViewModel(sections: productSections)
                    bind(productListViewModel)
                    
                    self.sheet = .init(type: .productList(productListViewModel))
                                       
            //Rename Item start
                case let payload as TemplatesListViewModelAction.Item.Rename:
                    
                    guard let data = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == payload.itemId}),
                          let itemVM = itemsRaw.value.first(where: { $0.id == payload.itemId})
                    else { return }
                    
                    let renameTemplateItemViewModel = RenameTemplateItemViewModel(oldName: itemVM.title,
                                                                                  templateID: data.id)
                    bind(renameTemplateItemViewModel)
                    
                    self.sheet = .init(type: .renameItem(renameTemplateItemViewModel))
                    
            //Item Tapped
                case let payload as TemplatesListViewModelAction.Item.Tapped:
                    guard let template = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == payload.itemId }),
                          let item = self.items.first(where: { $0.id == payload.itemId })
                    else { return }
                    
                    switch template.type {
                    case .betweenTheir:
                        guard let paymentsMeToMeViewModel = PaymentsMeToMeViewModel(
                            model,
                            mode: .templatePayment(template.id, item.title)) else {
                            
                            return
                        }
                        
                        bind(paymentsMeToMeViewModel)
                        
                        sheet = .init(type: .meToMe(paymentsMeToMeViewModel))
                        
                    default:
                        openDefaultPayment(template)
                    }
            //MARK: Search
                case let payload as TemplatesListViewModelAction.Search:
                    
                    withAnimation {
                        
                        self.items = reduceItems(rawItems: self.itemsRaw.value,
                                                 isDataUpdating: model.paymentTemplatesUpdating.value,
                                                 categorySelected: self.categorySelector?.selected,
                                                 searchText: payload.text,
                                                 isAddItemNeeded: true)
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
    
                    updateNavBar(event: .setRegular)
                    //save settings style
                    var settings = model.settingsPaymentTemplates
                    settings.update(style: style)
                    model.settingsPaymentTemplatesUpdate(settings)
                    
                case _ as TemplatesListViewModelAction.RegularNavBar.SearchNavBarPresent:
                    
                    updateNavBar(event: .setSearch)
                    
                case _ as TemplatesListViewModelAction.RegularNavBar.RegularNavBarPresent:
                    
                    updateNavBar(event: .setRegular)
            
        //MARK: Enabled Reorder
                case _ as TemplatesListViewModelAction.ReorderItems.EditModeEnabled:
                    
                    withAnimation {
                        
                        if case .tiles = self.style { self.style = .list }
                        
                        self.categorySelector = nil
                        self.items = self.itemsRaw.value
                        self.editModeState = .active
                        self.updateNavBar(event: .setReorder)
                    }
              
            //Close Reorder
                case _ as TemplatesListViewModelAction.ReorderItems.CloseEditMode:
            
                    let newCategorySelector = getCategorySelectorModel(with: model.paymentTemplates.value)
                    
                    withAnimation {
                        self.state = .normal
                        self.editModeState = .inactive
                        self.style = model.settingsPaymentTemplates.style
                        self.updateNavBar(event: .setRegular)
                        self.categorySelector = newCategorySelector
                        bindCategorySelector(newCategorySelector)
                   }
                
            //Save Reorder
                case _ as TemplatesListViewModelAction.ReorderItems.SaveReorder:
                    
                    self.editModeState = .inactive
                    self.state = .placeholder
                    self.style = model.settingsPaymentTemplates.style
                    self.updateNavBar(event: .setRegular)
                    
                    var sortIndex = 1
                    let newOrders = items.reduce(into: [PaymentTemplateData.SortData]()) { payloadData, itemVM in
                        
                        if let data = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == itemVM.id }) {
                            payloadData.append(.init(paymentTemplateId: data.id, sort: sortIndex))
                            sortIndex += 1
                        }
                    }
                    
                    guard !newOrders.isEmpty
                    else {
                        self.action.send(TemplatesListViewModelAction.ReorderItems.CloseEditMode())
                        return
                    }
                    
                    model.action.send(ModelAction.PaymentTemplate.Sort.Requested(sortDataList: newOrders))
                    
            // Item Moved
                case let payload as TemplatesListViewModelAction.ReorderItems.ItemMoved:

                    self.items = Self.reduce(rawItems: self.items, move: payload.move)
                    
                    self.navBarState
                        .reorderModel?
                        .isTrailingButtonDisable = self.items.map(\.id) == self.itemsRaw.value.map(\.id)
                    
        //MARK: - MultiDeleting
                    
                case _ as TemplatesListViewModelAction.Delete.Selection.Enter:
                    
                    withAnimation {
                        
                        self.state = .select
                        updateNavBar(event: .setDelete)
                        self.selectedItemsIds.value = []
                        self.deletePanel = getDeletePanelModel(selectedCount: 0)
                        
                        self.items = reduceItems(rawItems: self.itemsRaw.value,
                                                 isDataUpdating: false,
                                                 categorySelected: self.categorySelector?.selected,
                                                 searchText: nil,
                                                 isAddItemNeeded: false)
                        
                        for item in itemsRaw.value {
                            
                            item.state = .select(.init(isSelected: false, action: {[weak self] itemId in
                                
                                self?.action.send(TemplatesListViewModelAction.Delete.Selection.ToggleItem(itemId: itemId))
                                
                            }))
                        }
                    }
                //Exit in Select State
                case _ as TemplatesListViewModelAction.Delete.Selection.Exit:
                    
                    withAnimation {
                        
                        state = .normal
                        updateNavBar(event: .setRegular)
                        selectedItemsIds.value = []
                        deletePanel = nil
                        
                        for item in itemsRaw.value {
                            
                            item.state = .normal
                        }
                    }

                case let payload as TemplatesListViewModelAction.Delete.Selection.ToggleItem:
                    
                    guard let item = itemsRaw.value.first(where: { $0.id == payload.itemId})
                    else { return }
                    
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
              //SelectAll
                case _ as TemplatesListViewModelAction.Delete.Selection.Toggle:
                    
                    let action: (ItemViewModel.ID) -> Void = {[weak self] itemId in
                        
                        self?.action.send(TemplatesListViewModelAction.Delete.Selection.ToggleItem(itemId: itemId))
                    }
                    
                    if selectedItemsIds.value.count == items.count {
                        //deselect all
                        for item in items {
                            if selectedItemsIds.value.contains(item.id) {
                                
                                selectedItemsIds.value.remove(item.id)
                                item.state = .select(.init(isSelected: false, action: action))
                            }
                        }
                        
                    } else {
                        //select all
                        for item in items {
                            if !selectedItemsIds.value.contains(item.id) {
                                
                                selectedItemsIds.value.insert(item.id)
                                item.state = .select(.init(isSelected: true, action: action))
                            }
                        }
                    }
                
            //Multi Deleting Start
                case _ as TemplatesListViewModelAction.Delete.Selection.Accept:
                    
                    let deleteGroupItemsId = self.selectedItemsIds.value
                    
                    self.action.send(TemplatesListViewModelAction.Delete.Selection.Exit())
                    
                    let itemVM = TemplatesListViewModel.ItemViewModel
                        .init(title: "Выбрано \(deleteGroupItemsId.count)",
                              kind: .deleting)
                    
                    itemVM.timer = DeletingTimer()
                    guard let timer = itemVM.timer else { return }
                    
                    let deletingViewModel = ItemViewModel.DeletingProgressViewModel
                        .init(progress: timer.maxCount,
                              countTitle: "\(timer.maxCount)",
                              cancelButton: .init(title: "Отменить",
                                                  action: { [unowned itemVM, unowned self] id in
                                    itemVM.timer = nil
                                    self.action.send(
                                        TemplatesListViewModelAction.Delete.Selection.CancelDeleting())
                                    }),
                              title: itemVM.title,
                              style: self.style,
                              id: itemVM.id)
                    
                    itemVM.state = .deleting(deletingViewModel)
                    
                    withAnimation {
                        
                        self.items.removeAll { deleteGroupItemsId.contains($0.id) }
                        self.items.insert(itemVM, at: 0)
                    }
                    self.idList = UUID() //focus on first item in list
                    
                    itemVM.timer?.timerPublisher
                        .receive(on: scheduler)
                        .map({ [unowned timer] output in
                            return Int(output.timeIntervalSince(timer.startDate))
                        })
                        .sink { [unowned self, unowned timer] timerValue in
                            
                            let current = timer.maxCount - timerValue
                            deletingViewModel.progress = current
                            deletingViewModel.countTitle = "\(current)"
                            
                            if current == 0 {
                                
                                deletingViewModel.isDisableCancelButton = true
                                model.action.send(ModelAction.PaymentTemplate.Delete.Requested
                                    .init(paymentTemplateIdList: Array(deleteGroupItemsId)))
                                
                                itemVM.timer = nil
                            }
                    }
                    .store(in: &bindings)
                    
            //Multi Deleting cancel
                case _ as TemplatesListViewModelAction.Delete.Selection.CancelDeleting:
                    
                    withAnimation {
                        
                        self.updateNavBar(event: .setRegular)
                            
                        self.items = reduceItems(rawItems: self.itemsRaw.value,
                                                 isDataUpdating: model.paymentTemplatesUpdating.value,
                                                 categorySelected: self.categorySelector?.selected,
                                                 searchText: nil,
                                                 isAddItemNeeded: true)
                    }
                    
            //Personal Item Delete start
                case let payload as TemplatesListViewModelAction.Item.Delete:
                    
                    guard let _ = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == payload.itemId}),
                          let itemModel = itemsRaw.value.first(where: { $0.id == payload.itemId})
                    else { return }
                    
                    itemModel.timer = DeletingTimer()
                    guard let timer = itemModel.timer else { return }
                    
                    let deletingViewModel = ItemViewModel.DeletingProgressViewModel
                        .init(progress: timer.maxCount,
                              countTitle: "\(timer.maxCount)",
                              cancelButton: .init(title: "Отменить",
                                                  action: { [unowned itemModel, unowned self] id in
                            itemModel.timer = nil
                            itemModel.state = .normal
                            
                            if !self.isDeleteProcessing, self.isExistDeleted  {
                                model.action.send(ModelAction.PaymentTemplate.List.Requested())
                            }
                        }),
                              title: itemModel.title,
                              style: self.style,
                              id: itemModel.id)
                    
                    itemModel.state = .deleting(deletingViewModel)
                    
                    itemModel.timer?.timerPublisher
                        .receive(on: scheduler)
                        .map({ [unowned timer] output in
                            return Int(output.timeIntervalSince(timer.startDate))
                        })
                        .sink { [unowned self, unowned timer] timerValue in
                            
                            let current = timer.maxCount - timerValue
                            deletingViewModel.progress = current
                            deletingViewModel.countTitle = "\(current)"
                            
                            if current == 0 {
                                
                                deletingViewModel.isDisableCancelButton = true
                                itemModel.timer = nil
                                
                                model.action.send(ModelAction.PaymentTemplate.Delete.Requested
                                    .init(paymentTemplateIdList: [itemModel.id]))
                            }
                    }
                    .store(in: &bindings)
                    
            //CloseLink
                case _ as TemplatesListViewModelAction.CloseAction:
                    link = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        // selected items updates
        selectedItemsIds
            .receive(on: scheduler)
            .sink { [unowned self] selected in
                
                if case .select = self.state {
                    
                    deletePanel = getDeletePanelModel(selectedCount: selected.count)
                }
                
            }.store(in: &bindings)
         
        $editModeState
            .dropFirst()
            .receive(on: scheduler)
            .sink { [unowned self] state in
                
                switch state {
                case .active: self.idList = UUID()
                    
                default: return
                }
            }.store(in: &bindings)
    }
    
    private func openDefaultPayment(
        _ template: PaymentTemplateData
    ) {
        link = .payment(.init(
            source: .template(template.id),
            model: model,
            closeAction: { [weak self] in
                
                self?.action.send(TemplatesListViewModelAction.CloseAction())
            }
        ))
    }
    
    func bindCategorySelector(_ viewModel: OptionSelectorView.ViewModel) {
        
        viewModel.$selected
            .receive(on: scheduler)
            .sink{ [unowned self]  selectedCategoryIndex in
                
                withAnimation {
                 
                    self.items = reduceItems(rawItems: self.itemsRaw.value,
                                             isDataUpdating: false,
                                             categorySelected: selectedCategoryIndex,
                                             searchText: self.navBarState.searchModel?.searchText,
                                             isAddItemNeeded: !self.state.isSelect)
                }
            }.store(in: &bindings)
    }
    
    func bind(_ viewModel: RenameTemplateItemViewModel) {
            
        viewModel.action
            .compactMap { $0 as? TemplatesListViewModelAction.RenameSheetAction.SaveNewName }
            .receive(on: scheduler)
            .sink { [unowned self] payload in
                
                viewModel.isFocused = false
                self.sheet = nil
                
                guard let item = items.first(where: { $0.id == payload.itemId}) else { return }
                
                item.state = .processing
                self.model.action.send(ModelAction.PaymentTemplate.Update.Requested
                                        .init(name: payload.newName,
                                              parameterList: nil,
                                              paymentTemplateId: payload.itemId))
            }
            .store(in: &bindings)
    }
    
    private func bind(_ viewModel: ProductListViewModel) {
        
        for section in viewModel.sections {
            
            section.action
                .receive(on: scheduler)
                .sink { [unowned self]  action in
                    
                    switch action {
                    case let payload as MyProductsSectionViewModelAction.Events.ItemTapped:
                       
                        self.sheet = nil
                        guard let product = model.products.value.values
                                                .flatMap({ $0 })
                                                .first(where: { $0.id == payload.productId })
                        else { return }
                        
                        self.action.send(TemplatesListViewModelAction.OpenProductProfile
                                            .init(productId: product.id))
                    default: break
                    }
            }.store(in: &bindings)
            
            section.$isCollapsed
                .receive(on: scheduler)
                .sink { [unowned viewModel] isCollapsed in
                    
                    viewModel.containerHeight = viewModel.calcHeight
                    
            }.store(in: &bindings)
        }
    }
    
    /// Сlosing success screen
    func bind(_ viewModel: PaymentsSuccessViewModel) {
        
        viewModel.action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsSuccessAction.Button.Close:
                    self.updateFastAll()
                    self.action.send(ProductProfileViewModelAction.Close.Success())
                    self.action.send(PaymentsTransfersViewModelAction.Close.DismissAll())
                    self.success = nil
                    self.sheet = nil
                        
                default:
                    break
                }

            }.store(in: &bindings)
    }
    
    private func bind(_ viewModel: PaymentsMeToMeViewModel) {
        
        viewModel.action
            .receive(on: scheduler)
            .sink { [unowned self, weak viewModel] action in
                
                switch action {
                case let payload as PaymentsMeToMeAction.Response.Success:
                    
                    guard let productIdFrom = viewModel?.swapViewModel.productIdFrom,
                          let productIdTo = viewModel?.swapViewModel.productIdTo else {
                        return
                    }
                    
                    model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: productIdFrom))
                    model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: productIdTo))
                        
                    bind(payload.viewModel)
                    success = payload.viewModel
                        
                case _ as PaymentsMeToMeAction.Close.BottomSheet:
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())

                case let payload as PaymentsMeToMeAction.InteractionEnabled:
                    
                    guard let bottomSheet = sheet else {
                        return
                    }
                    
                    bottomSheet.isUserInteractionEnabled.value = payload.isUserInteractionEnabled
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Settings

extension TemplatesListViewModel {
    
    typealias UpdateFastAll = () -> Void
    
    struct Route {
        
        var link: Link?
        var modal: Modal?
    }
    
    enum Modal {
        
        case alert(Alert.ViewModel)
        case sheet(Sheet)
    }
    
    var link: Link? {
        
        get { route.link }
        set { route.link = newValue }
    }
    
    var alert: Alert.ViewModel? {
        
        get {
            guard case let .alert(alert) = route.modal else { return nil }
            return alert
        }
        
        set {
            route.modal = newValue.map(Modal.alert)
        }
    }
    
    var sheet: Sheet? {
        
        get {
            guard case let .sheet(sheet) = route.modal else { return nil }
            return sheet
        }
        
        set {
            route.modal = newValue.map(Modal.sheet)
        }
    }
    
    struct Sheet: BottomSheetCustomizable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case meToMe(PaymentsMeToMeViewModel)
            case renameItem(RenameTemplateItemViewModel)
            case productList(ProductListViewModel)
        }
    }
    
    struct FullCover: Identifiable {
           
        let id = UUID()
        let type: Kind
           
        enum Kind {
            case successMeToMe(PaymentsSuccessViewModel)
        }
    }
    
    class ProductListViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        let title = "Выберите продукт"
        
        @Published var sections: [MyProductsSectionViewModel]
        @Published var containerHeight: CGFloat
        
        var calcHeight: CGFloat {
            
            var height: CGFloat = 16
            for section in sections {
                
                if section.isCollapsed {
                    height += 48 + 16
                } else {
                    height += CGFloat(section.items.count) * 72 + 48 + 16
                }
            }
            
            return height
        }
        
        init(sections: [MyProductsSectionViewModel],
             containerHeight: CGFloat = 80) {
            self.sections = sections
            self.containerHeight = containerHeight
        }
        
    }
    
    class RenameTemplateItemViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        let saveButtonText = "Сохранить"
        let textFieldLabel = "Введите название шаблона"
        let oldName: String
        let templateID: ItemViewModel.ID
        
        @Published var text: String
        @Published var isFocused: Bool
        
        var clearButton: NavigationBarButtonViewModel? {
            text.isEmpty ? nil : .init(icon: .ic24Close,
                                       action: { self.text = "" } )
        }
        
        var isNameNotValid: Bool {
            
            self.text.count < 1 || self.text == self.oldName
        }
        
        var saveButtonAction: () -> Void {
            
            { [unowned self] in self.action.send(TemplatesListViewModelAction.RenameSheetAction.SaveNewName
                .init(newName: self.text, itemId: self.templateID))
            }
        }
        
        init(oldName: String,
             templateID: ItemViewModel.ID,
             isFocused: Bool = true) {
            
            self.oldName = oldName
            self.templateID = templateID
            self.text = oldName
            self.isFocused = isFocused
        }
    }
    
    enum Link {
        
        case payment(PaymentsViewModel)
    }
}

//MARK: - Template Items View Models

private extension TemplatesListViewModel {
    
    func reduceItems(rawItems: [ItemViewModel],
                     isDataUpdating: Bool,
                     categorySelected: Option.ID?,
                     searchText: String?,
                     isAddItemNeeded: Bool) -> [ItemViewModel] {
            
        var newItems = rawItems
        
        if let searchText, !searchText.isEmpty {
            newItems = searchedItems(newItems, searchText)
        }
        
        if let categorySelected {
            newItems = sortedItems(filterredItems(newItems, categorySelected))
        }
          
        if isDataUpdating {
            newItems.insert(ItemViewModel(kind: .placeholder), at: 0)
        }
        
        if isAddItemNeeded {
            newItems.append(getItemAddNewTemplateModel())
        }
        
        return newItems
        
    }
    
    static func reduce(rawItems: [ItemViewModel], move: (from: IndexSet.Element, to: Int)) -> [ItemViewModel] {
        
        var updatedItems = rawItems
        let removed = updatedItems.remove(at: move.from)

        if move.from < move.to {
            updatedItems.insert(removed, at: move.to != 0 ? move.to - 1 : 0)
        
        } else {
            updatedItems.insert(removed, at: move.to)
        }
        
        return updatedItems
    }
}

//MARK: - Filtering & Sorting ItemsModel

extension TemplatesListViewModel {
    
    func sortedItems(_ rawItems: [ItemViewModel]) -> [ItemViewModel] {
        
        return rawItems.sorted(by: { $0.sortOrder < $1.sortOrder })
    }
    
    func filterredItems(_ rawItems: [ItemViewModel], _ selectedCategoryIndex: String) -> [ItemViewModel] {
        
        if selectedCategoryIndex == categoryIndexAll {
            
            return rawItems
            
        } else {
            
            return rawItems.filter{ $0.subTitle == selectedCategoryIndex }
        }
    }
    
    func searchedItems(_ rawItems: [ItemViewModel], _ searchText: String) -> [ItemViewModel] {
        
        if searchText.isEmpty {
            
            return rawItems
            
        } else {
            
            return rawItems.filter({$0.title.localizedCaseInsensitiveContains(searchText)})
                
        }
    }
}

//MARK: - Local View Models

extension TemplatesListViewModel {
    
    func getCategorySelectorModel(with templates: [PaymentTemplateData])
    -> OptionSelectorView.ViewModel {
        
        let groupNames = templates.map(\.groupName)
        var groupNamesUnique = Set(groupNames)
        let optionAll = Option(id: categoryIndexAll, name: "Все")
        var options = [optionAll]
        
        for groupName in groupNames {
            
            if groupNamesUnique.contains(groupName) {
                options.append(Option(id: groupName, name: groupName))
                groupNamesUnique.remove(groupName)
            }
        }
        
        return .init(options: options, selected: optionAll.id, style: .template)
    }
    
    func isCategorySelectorContainsCategory(categoryId: Option.ID) -> Bool {
        
        guard let categorySelector = categorySelector else {
            return false
        }
        
        let categoriesIds = categorySelector.options.map{ $0.id }
        
        return categoriesIds.contains(categoryId)
    }
    
    func getDeletePanelModel(selectedCount: Int) -> DeletePannelViewModel {
        
        .init(description: "Выбрано \(selectedCount)",
              selectAllButton: .init(icon: .ic24CheckCircle,
                                     title: "Выбрать все",
                                     isDisable: false,
                                     action: {[weak self] in self?.action.send(TemplatesListViewModelAction.Delete.Selection.Toggle()) }),
              deleteButton: .init(icon: .ic24Trash2,
                                  title: "Удалить",
                                  isDisable: selectedCount == 0,
                                  action: {[weak self] in self?.action.send(TemplatesListViewModelAction.Delete.Selection.Accept()) }))
    }
    
    func getEmptyTemplateListViewModel() -> EmptyTemplateListViewModel {
        
        .init(icon: .ic40Star,
              title: "Нет шаблонов",
              message: "Вы можете создать шаблон из любой успешной операции в разделе История",
              button: .init(title: "Перейти в историю",
                            action: { [weak self] in self?.action.send(TemplatesListViewModelAction.AddTemplateTapped())}))
    }
}

//MARK: - Internal Components

extension TemplatesListViewModel {
    
    enum State {
        
        case emptyList(EmptyTemplateListViewModel)
        case normal
        case select
        case placeholder
        
        var emptyListModel: EmptyTemplateListViewModel? {
            
            if case .emptyList(let viewModel) = self {
                return viewModel
            } else {
                return nil
            }
        }
        
        var isSelect: Bool {
            
            if case .select = self {
                return true
            } else {
                return false
            }
        }
        
        var isPlaceholder: Bool {
            
            if case .placeholder = self {
                return true
            } else {
                return false
            }
        }
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
        let selectAllButton: PanelButtonViewModel
        let deleteButton: PanelButtonViewModel
        
        init(description: String,
             selectAllButton: PanelButtonViewModel,
             deleteButton: PanelButtonViewModel) {
            
            self.description = description
            self.selectAllButton = selectAllButton
            self.deleteButton = deleteButton
        }
    }
    
    class PanelButtonViewModel {
        
        let icon: Image
        let title: String
        let isDisable: Bool
        let action: () -> Void
        
        init(icon: Image, title: String, isDisable: Bool, action: @escaping () -> Void) {
            self.icon = icon
            self.title = title
            self.isDisable = isDisable
            self.action = action
        }
    }
    
    struct EmptyTemplateListViewModel {
        
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

enum TemplateViewModelAction {
    
    enum CloseAction {
     
        struct Link: Action {}

    }
}
