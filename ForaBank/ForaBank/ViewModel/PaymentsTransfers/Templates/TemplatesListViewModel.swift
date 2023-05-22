//
//  TemplatesListViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 18.01.2022.
//

//import Foundation
import SwiftUI
import Combine

class TemplatesListViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var state: State
    @Published var style: Style
    @Published var navBarState: NavBarState
    @Published var editModeState: EditMode = .inactive
    
    @Published var categorySelector: OptionSelectorView.ViewModel?
    @Published var deletePannel: DeletePannelViewModel?
    
    @Published var items: [ItemViewModel]

    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var sheet: Sheet?
    
    private let model: Model
    var bindings = Set<AnyCancellable>()
    
    private let selectedItemsIds: CurrentValueSubject<Set<ItemViewModel.ID>, Never> = .init([])
    private let itemsRaw: CurrentValueSubject<[ItemViewModel], Never> = .init([])
    private let categoryIndexAll = "TemplatesListViewModelCategoryAll"
    let dismissAction: () -> Void
    
    internal init(state: State, style: Style,
                  navBarState: NavBarState,
                  categorySelector: OptionSelectorView.ViewModel?,
                  items: [ItemViewModel],
                  deletePannel: DeletePannelViewModel?,
                  dismissAction: @escaping () -> Void = {},
                  model: Model) {
        
        self.state = state
        self.style = style
        self.navBarState = navBarState
        self.categorySelector = categorySelector
        self.items = items
        self.deletePannel = deletePannel
        self.dismissAction = dismissAction
        self.model = model
    }
    
    convenience init(_ model: Model, dismissAction: @escaping () -> Void) {
        
        self.init(state: .normal,
                  style: model.paymentTemplatesViewSettings.value.style,
                  navBarState: .regular(nil),
                  categorySelector: nil,
                  items: [],
                  deletePannel: nil,
                  dismissAction: dismissAction,
                  model: model)
        
        updateNavBar(state: .regular(nil))
        self.model.action.send(ModelAction.PaymentTemplate.List.Requested())
        bind()
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
                    
                    if templates.isEmpty {
                        
                        state = .emptyList(getEmptyTemplateListViewModel())
                        itemsRaw.value = []
                        categorySelector = nil
                        
                    } else {
                        
                        state = .normal
                        itemsRaw.value = templates.compactMap{ itemViewModel(with: $0) }
                        categorySelector = categorySelectorViewModel(with: templates)
                        bindCategorySelector()
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
            
            //Rename Item start
                case let payload as TemplatesListViewModelAction.Item.Rename:
                    
                    guard let data = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == payload.itemId}),
                          let _ = itemsRaw.value.first(where: { $0.id == payload.itemId})
                    else { return }
                    
                    let renameTemplateItemViewModel = RenameTemplateItemViewModel(oldName: data.name,
                                                                                  templateID: data.id)
                    bind(renameTemplateItemViewModel)
                    
                    self.sheet = .init(type: .renameItem(renameTemplateItemViewModel))
            
            //Personal Item Delete start
                case let payload as TemplatesListViewModelAction.Item.Delete:
                    guard let _ = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == payload.itemId}),
                          let itemVM = itemsRaw.value.first(where: { $0.id == payload.itemId})
                    else { return }
                    
                    itemVM.timer = MyTimer()
                    guard let timer = itemVM.timer else { return }
                    
                    let deletingViewModel = ItemViewModel.DeletingProgressViewModel
                        .init(progress: 0,
                              countTitle: "\(timer.maxCount)",
                              cancelButton: .init(title: "Отменить",
                                                  action: { [unowned itemVM] id in
                                                                itemVM.timer = nil
                                                                itemVM.state = .normal }),
                              title: itemVM.title,
                              style: self.style,
                              id: itemVM.id)
                    
                    itemVM.state = .deleting(deletingViewModel)
                    
                    itemVM.timer?.timerPublish
                        .receive(on: DispatchQueue.main)
                        .map({ [unowned timer] output in
                            return Int(output.timeIntervalSince(timer.startDate))
                        })
                        .sink { [unowned self, unowned timer] timerValue in
                            
                            if timerValue < timer.maxCount + 1 {

                                deletingViewModel.progress = timerValue
                                deletingViewModel.countTitle = "\(timer.maxCount - timerValue)"

                            } else {
                                
                                model.action.send(ModelAction.PaymentTemplate.Delete.Requested(paymentTemplateIdList: [itemVM.id]))
                                
                                itemVM.timer = nil
                                itemVM.state = .normal
                            }
                        }
                        .store(in: &bindings)
                    
                case let payload as TemplatesListViewModelAction.Item.Tapped:
                    guard let data = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == payload.itemId})
                    else { return }
                    
                    switch data.type {
                        
                    case .otherBank:
                        //TODO: set action
                        break
                        
                    case .betweenTheir:
                        link = .betweenTheir(.init(type: .template(data), closeAction: {[weak self] in
                            
                            self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }))
                        
                    case .insideBank:
                        link = .betweenTheir(.init(type: .template(data), closeAction: {[weak self] in self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }))
                        
                    case .byPhone:
                        link = .byPhone(.init(insideByPhone: data, closeAction: {[weak self] in
                            self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }))
                        
                    case .sfp:
                        link = .byPhone(.init(spf: data, closeAction: {[weak self] in
                            self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }))

                    case .direct:
                        let operatorsViewModel = OperatorsViewModel(mode: .template(data), closeAction: {  [weak self] in
                            self?.action.send(TemplatesListViewModelAction.CloseAction()) })
                        link = .direct(CountryPaymentView.ViewModel(operatorsViewModel: operatorsViewModel))
                        
                    case .contactAdressless:
                        let operatorsViewModel = OperatorsViewModel(mode: .template(data), closeAction: {  [weak self] in
                            self?.action.send(TemplatesListViewModelAction.CloseAction()) }, requisitsViewAction: {})
                        link = .contactAdressless(CountryPaymentView.ViewModel(operatorsViewModel: operatorsViewModel))
                        
                    case .housingAndCommunalService:
                        link = .housingAndCommunalService(.init(model: model, closeAction: {[weak self] in self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }, paymentTemplate: data))

                    case .mobile:
                        link = .mobile(.init(paymentTemplate: data, closeAction: {[weak self] in
                            
                            self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }))
                        
                    case .internet:
                        link = .internet(.init(model: model, closeAction: {[weak self] in
                            
                            self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }, paymentTemplate: data))

                    case .transport:
                        link = .internet(.init(model: model, closeAction: {[weak self] in
                            
                            self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }, paymentTemplate: data))

                    case .externalEntity:
                        link = .externalEntity(.init(type: .template(data), closeAction: {[weak self] in self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }))

                    case .externalIndividual:
                        link = .externalIndividual(.init(type: .template(data), closeAction: {[weak self] in self?.action.send(TemplatesListViewModelAction.CloseAction())
                        }))

                    default:
                        break
                    }
                
                case let payload as TemplatesListViewModelAction.Search:
                    
                    self.items = searchedItems(itemsRaw.value, payload.text)
                    updateAddNewTemplateItem()
                    
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
    
                    updateNavBar(state: .regular(nil))
                    
                case _ as TemplatesListViewModelAction.RegularNavBar.SearchNavBarPresent:
                    
                    updateNavBar(state: .search(nil))
                    
                case _ as TemplatesListViewModelAction.RegularNavBar.RegularNavBarPresent:
                    
                    let regularNavBarViewModel: RegularNavBarViewModel =
                    
                        .init(backButton: .init(icon: .ic24ChevronLeft, action: self.dismissAction),
                              menuList: self.getMenuListViewModel(),
                              searchButton: .init(icon: .ic24Search, action: {
                            self.action.send(TemplatesListViewModelAction.RegularNavBar.SearchNavBarPresent()) }))
                                
                    self.navBarState = .regular(regularNavBarViewModel)
            
            // Enabled Reorder
                case _ as TemplatesListViewModelAction.ReorderItems.EditModeEnabled:
                    
                    withAnimation {
                        
                        if case .tiles = self.style { self.style = .list }
                        
                        self.categorySelector = nil
                        self.items = self.itemsRaw.value
                        self.editModeState = .active
                        self.updateNavBar(state: .reorder(nil))
                    }
              
            //Close Reorder
                case _ as TemplatesListViewModelAction.ReorderItems.CloseEditMode:
            
                    withAnimation {
                        
                        self.editModeState = .inactive
                        self.updateNavBar(state: .regular(nil))
                        self.items = self.itemsRaw.value
                        categorySelector = categorySelectorViewModel(with: model.paymentTemplates.value)
                    }
                    
                    bindCategorySelector()
                    self.updateAddNewTemplateItem()
                
            //Save Reorder
                case _ as TemplatesListViewModelAction.ReorderItems.SaveReorder:
                    
                    self.editModeState = .inactive
                    self.updateNavBar(state: .regular(nil))
                    
                    var sortIndex = 1
                    let newOrders = items.reduce(into: [PaymentTemplateData.SortData]()) { payloadData, itemVM in
                        if let data = model.paymentTemplates.value.first(where: { $0.paymentTemplateId == itemVM.id }) {
                            payloadData.append(.init(paymentTemplateId: data.id, sort: sortIndex))
                            itemVM.sortOrder = sortIndex
                            sortIndex += 1
                        }
                    }
                    
                    guard !newOrders.isEmpty else { return }
                    
                    model.action.send(ModelAction.PaymentTemplate.Sort.Requested(sortDataList: newOrders))
                    
                    withAnimation {
                        categorySelector = categorySelectorViewModel(with: model.paymentTemplates.value)
                    }
                   
                    bindCategorySelector()
                    self.itemsRaw.value = self.items
              
            // Item Moved
                case let payload as TemplatesListViewModelAction.ReorderItems.ItemMoved:

                    self.items = Self.reduce(items: self.items, move: payload.move)
                    
                case _ as TemplatesListViewModelAction.Delete.Selection.Enter:
                    
                    withAnimation {
                        
                        self.state = .select
                        updateNavBar(state: .delete(nil))
                        self.selectedItemsIds.value = []
                        self.deletePannel = deletePannelViewModel(selectedCount: 0)
                        
                        for item in itemsRaw.value {
                            
                            item.state = .select(.init(isSelected: false, action: {[weak self] itemId in
                                
                                self?.action.send(TemplatesListViewModelAction.Delete.Selection.ToggleItem(itemId: itemId))
                                
                            }))
                        }
                    }

                case _ as TemplatesListViewModelAction.Delete.Selection.Exit:
                    
                    withAnimation {
                        
                        state = .normal
                        updateNavBar(state: .regular(nil))
                        selectedItemsIds.value = []
                        deletePannel = nil
                        
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
                case _ as TemplatesListViewModelAction.Delete.Selection.SelectAll:
                    
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
                    
                case _ as TemplatesListViewModelAction.Delete.Selection.Accept:
                    
                    self.action.send(TemplatesListViewModelAction.Delete.Selection.Exit())
                    
                    for itemId in selectedItemsIds.value {
                      
                        self.action.send(TemplatesListViewModelAction.Item.Delete(itemId: itemId))
                    }
                    
                case _ as TemplatesListViewModelAction.CloseAction:
                    link = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        // change editMode
//        $editModeState
//            .receive(on: DispatchQueue.main)
//            .sink { [unowned self] editMode in
//
//                if editMode == .active {
//
//                    action.send(TemplatesListViewModelAction.ReorderItems.EditModeEnabled())
//                }
//
//            }.store(in: &bindings)
        
        // selected items updates
        selectedItemsIds
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] selected in
                
                if case .select = self.state {
                    
                    deletePannel = deletePannelViewModel(selectedCount: selected.count)
                }
                
            }.store(in: &bindings)
        
        // state changes
        $state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                withAnimation {
                    
                    //updateTitle()
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
               
                var tempItems = itemsRaw.value
                
                if case .search(let viewModel) = navBarState,
                   let viewModel,
                   !viewModel.searchText.isEmpty {
                    
                    tempItems = searchedItems(tempItems, viewModel.searchText)
                }
                
                self.items = sortedItems(filterredItems(tempItems, selectedCategoryIndex))
               
                updateAddNewTemplateItem()
                
            }.store(in: &bindings)
    }
    
    func bind(_ viewModel: RenameTemplateItemViewModel) {
            
        viewModel.action
            .compactMap { $0 as? TemplatesListViewModelAction.RenameSheetAction.SaveNewName }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] payload in
                
                viewModel.isFocused = false
                self.sheet = nil
                
                guard let item = items.first(where: { $0.id == payload.itemId}) else { return }
                
                item.title = payload.newName
                self.model.action.send(ModelAction.PaymentTemplate.Update.Requested
                                        .init(name: payload.newName,
                                              parameterList: nil,
                                              paymentTemplateId: payload.itemId))
            }
            .store(in: &bindings)
        
    }
}

//MARK: - Settings

extension TemplatesListViewModel {
    
    struct Settings: Codable {
        
        let style: Style
        
        static let initial = Settings(style: .list)
    }
    
    struct Sheet: BottomSheetCustomizable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case betweenTheir(MeToMeViewModel)
            case renameItem(RenameTemplateItemViewModel)
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
            
            self.text.count < 3 || self.text == self.oldName
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

        case byPhone(PaymentByPhoneViewModel)
        case sfp(PaymentByPhoneViewModel)
        case direct(CountryPaymentView.ViewModel)
        case contactAdressless(CountryPaymentView.ViewModel)
        case housingAndCommunalService(InternetTVDetailsViewModel)
        case mobile(MobilePayViewModel)
        case internet(InternetTVDetailsViewModel)
        case transport(OperatorsViewModel)
        case externalEntity(TransferByRequisitesViewModel)
        case externalIndividual(TransferByRequisitesViewModel)
        case betweenTheir(MeToMeViewModel)
                           
    }
}

//MARK: - Template Items View Models

private extension TemplatesListViewModel {
    
    static func reduce(items: [ItemViewModel], move: (from: IndexSet.Element, to: Int)) -> [ItemViewModel] {
        
        var updatedItems = items
        let removed = updatedItems.remove(at: move.from)

        if move.from < move.to {
            updatedItems.insert(removed, at: move.to != 0 ? move.to - 1 : 0)
        
        } else {
            updatedItems.insert(removed, at: move.to)
        }
        
        return updatedItems
        
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
    
    func searchedItems(_ items: [ItemViewModel], _ searchText: String) -> [ItemViewModel] {
        
        var tempItems = itemsRaw.value
        
        if let selectedCategoryIndex = categorySelector?.selected {
            
            tempItems = sortedItems(filterredItems(itemsRaw.value, selectedCategoryIndex))
        }
        
        if searchText.isEmpty {
            
            return tempItems
            
        } else {
            
            return tempItems.filter{ $0.title.capitalized.contains(searchText.capitalized) }
        }
        
    }
    
    func sortedItems(_ items: [ItemViewModel]) -> [ItemViewModel] {
        
        return items.sorted(by: { $0.sortOrder < $1.sortOrder })
    }
}

//MARK: - Navigation Buttons View Models

private extension TemplatesListViewModel {
    
    func cancelDeleteModeButtonViewModel() -> NavigationBarButtonViewModel {
        
        NavigationBarButtonViewModel(title: "", icon: Image("Templates Nav Icon Cancel"), action: {[weak self] in self?.action.send(TemplatesListViewModelAction.Delete.Selection.Exit()) })
    }
}

//MARK: - Local View Models

extension TemplatesListViewModel {
    
    func categorySelectorViewModel(with templates: [PaymentTemplateData]) -> OptionSelectorView.ViewModel {
        
        let groupNames = templates.map{ $0.groupName }
        let groupNamesUnique = Set(groupNames)
        let groupNamesSorted = Array(groupNamesUnique).sorted(by: { $0 < $1 })
        var options = groupNamesSorted.map{ Option(id: $0, name: $0) }
        let optionAll = Option(id: categoryIndexAll, name: "Все")
        options.insert(optionAll, at: 0)
        
        return OptionSelectorView.ViewModel(options: options, selected: optionAll.id, style: .template)
    }
    
    func isCategorySelectorContainsCategory(categoryId: Option.ID) -> Bool {
        
        guard let categorySelector = categorySelector else {
            return false
        }
        
        let categoriesIds = categorySelector.options.map{ $0.id }
        
        return categoriesIds.contains(categoryId)
    }
    
    func deletePannelViewModel(selectedCount: Int) -> DeletePannelViewModel {
        
        .init(description: "Выбрано \(selectedCount)",
              selectAllButton: .init(icon: .ic24CheckCircle,
                                     title: "Выбрать все",
                                     isDisable: false,
                                     action: {[weak self] in self?.action.send(TemplatesListViewModelAction.Delete.Selection.SelectAll()) }),
              deleteButton: .init(icon: .ic24Trash2,
                                  title: "Удалить",
                                  isDisable: selectedCount == 0,
                                  action: {[weak self] in self?.action.send(TemplatesListViewModelAction.Delete.Selection.Accept()) }))
    }
    
    func getEmptyTemplateListViewModel() -> EmptyTemplateListViewModel {
        
        .init(icon: Image("Templates Onboarding Icon"),
              title: "Нет шаблонов",
              message: "Вы можете создать шаблон из любой успешной операции в разделе История",
              button: .init(title: "Перейти в историю",
                            action: { [weak self] in self?.action.send(TemplatesListViewModelAction.AddTemplate())}))
    }
}


//MARK: - Updates

private extension TemplatesListViewModel {
    
    func updateAddNewTemplateItem() {
        
        switch state {
        case .normal:
            
            if self.items.isEmpty {
                
                self.items.append(itemAddNewTemplateViewModel())
                
            } else {
                
                guard let lastItem = self.items.last, lastItem.kind != .add
                else { return }
                
                self.items.append(itemAddNewTemplateViewModel())
            }
            
        default:
            guard let lastItem = items.last, lastItem.kind == .add else {
                return
            }
            
            items.removeLast()
        }
    }
    
}

//MARK: - Internal Components

extension TemplatesListViewModel {
    
    enum State {
        
        case emptyList(EmptyTemplateListViewModel)
        case normal
        case select
        //case placeholder(DeletePannelViewModel)
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
