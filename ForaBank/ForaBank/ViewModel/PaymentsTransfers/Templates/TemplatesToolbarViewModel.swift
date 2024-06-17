//
//  TemplatesNavBarViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 26.04.2023.
//

import SwiftUI
import Combine

extension TemplatesListViewModel {
    
    enum NavBarState {
        
        case regular(RegularNavBarViewModel)
        case search(SearchNavBarViewModel)
        case delete(TwoButtonsNavBarViewModel)
        case reorder(TwoButtonsNavBarViewModel)
        
        var regularModel: RegularNavBarViewModel? {
            
            if case .regular(let viewModel) = self {
                return viewModel
            } else {
                return nil
            }
        }
        
        var searchModel: SearchNavBarViewModel? {
            
            if case .search(let viewModel) = self {
                return viewModel
            } else {
                return nil
            }
        }
        
        var reorderModel: TwoButtonsNavBarViewModel? {
            
            if case .reorder(let viewModel) = self {
                return viewModel
            } else {
                return nil
            }
        }
        
        enum Events {
            case setRegular, setSearch, setDelete, setReorder
        }
    }
    
    class TwoButtonsNavBarViewModel: ObservableObject {
        
        let leadingButton: NavigationBarButtonViewModel
        let trailingButton: NavigationBarButtonViewModel
        let title: String
        @Published var isTrailingButtonDisable: Bool
        
        init(leadingButton: NavigationBarButtonViewModel,
             trailingButton: NavigationBarButtonViewModel,
             title: String,
             isTrailingButtonDisable: Bool) {
            
            self.leadingButton = leadingButton
            self.trailingButton = trailingButton
            self.title = title
            self.isTrailingButtonDisable = isTrailingButtonDisable
        }
    }
    
    class RegularNavBarViewModel: ObservableObject {
        
        let backButton: NavigationBarButtonViewModel
        let menuImage: Image
        @Published var title: String
        @Published var menuList: [MenuItemViewModel]
        @Published var searchButton: NavigationBarButtonViewModel
        @Published var isMenuDisable: Bool
        @Published var isSearchButtonDisable: Bool
        
        init(backButton: NavigationBarButtonViewModel,
             title: String = "Шаблоны",
             menuList: [MenuItemViewModel],
             menuImage: Image = .ic24MoreVertical,
             searchButton: NavigationBarButtonViewModel,
             isMenuDisable: Bool = false,
             isSearchButtonDisable: Bool = false) {
            
            self.backButton = backButton
            self.title = title
            self.menuList = menuList
            self.menuImage = menuImage
            self.searchButton = searchButton
            self.isMenuDisable = isMenuDisable
            self.isSearchButtonDisable = isSearchButtonDisable
        }
    }
    
    class SearchNavBarViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let trailIcon: Image
        var clearButton: NavigationBarButtonViewModel? {
            searchText.isEmpty ? nil : .init(icon: .ic24Close,
                                             action: { self.searchText = "" } )
        }
        
        lazy var closeButton: NavigationBarButtonViewModel = {
            
            .init(title: "Отмена", icon: Image("")) {
                self.action.send(TemplatesListViewModelAction.SearchNavBarAction.Close())
            }
        }()
        
        @Published var searchText: String
        @Published var isFocused: Bool
        
        init(trailIcon: Image = .ic24Search, searchText: String = "", isFocused: Bool = true) {
            self.trailIcon = trailIcon
            self.searchText = searchText
            self.isFocused = isFocused

        }
    }
    
    struct MenuItemViewModel: Identifiable {
        let id = UUID()
        let icon: Image
        let textImage: String
        let title: String
        let action: () -> Void
    }
    
    func updateNavBar(event: NavBarState.Events) {
        
        switch event {
        case .setRegular:
            
            let isButtonsDisable = self.state.isPlaceholder
            
            self.navBarState = .regular(.init(backButton: .init(icon: .ic24ChevronLeft, action: self.dismissAction),
                                              menuList: getMenuListViewModel(),
                                              searchButton: .init(icon: .ic24Search, action: {
                self.action.send(TemplatesListViewModelAction.RegularNavBar.SearchNavBarPresent()) }),
                                              isMenuDisable: isButtonsDisable,
                                              isSearchButtonDisable: isButtonsDisable))
            
        case .setSearch:
           
            let searchNavBarViewModel = SearchNavBarViewModel()
            self.navBarState = .search(searchNavBarViewModel)
            bind(searchNavBarViewModel)
            
        case .setDelete:
            
            self.navBarState = .delete(.init(leadingButton: .init(icon: .ic24ChevronLeft, action: self.dismissAction),
                                             trailingButton: .init(icon: .ic24Close, action: {
                self.action.send(TemplatesListViewModelAction.Delete.Selection.Exit())
            }),
                                             title: "Выбрать шаблоны",
                                             isTrailingButtonDisable: false))
        case .setReorder:
            
            self.navBarState = .reorder(.init(leadingButton: .init(icon: .ic24Close, action: {
                self.action.send(TemplatesListViewModelAction.ReorderItems.CloseEditMode())
            }),
                                             trailingButton: .init(icon: .ic24Check, action: {
                self.action.send(TemplatesListViewModelAction.ReorderItems.SaveReorder())
            }),
                                              title: "Последовательность",
                                              isTrailingButtonDisable: true))
        }
        
    }
    
    func getMenuListViewModel() -> [MenuItemViewModel] {
        
        var menuItems = [MenuItemViewModel]()
        
        let reorderMenuItem = MenuItemViewModel(icon: .ic24BarInOrder,
                                                textImage: "ic24BarInOrder",
                                                title: "Последовательность") { [weak self] in
            
            self?.action.send(TemplatesListViewModelAction.ReorderItems.EditModeEnabled())
        }
        menuItems.append(reorderMenuItem)
         
        
        switch style {
        case .list:
            let styleMenuItem = MenuItemViewModel(icon: .ic24Grid,
                                                  textImage: "ic24Grid",
                                                  title: "Вид (Плитка)") { [weak self] in
                self?.action.send(TemplatesListViewModelAction.ToggleStyle())
               
            }
            menuItems.append(styleMenuItem)
            
        case .tiles:
            let styleMenuItem = MenuItemViewModel(icon: .ic24List,
                                                  textImage: "ic24List",
                                                  title: "Вид (Список)") { [weak self] in
                self?.action.send(TemplatesListViewModelAction.ToggleStyle())
            }
            menuItems.append(styleMenuItem)
        }
        
        let deleteMenuItem = MenuItemViewModel(icon: .ic24Trash,
                                               textImage: "ic24Trash",
                                               title: "Удалить") { [weak self] in
            self?.action.send(TemplatesListViewModelAction.Delete.Selection.Enter())
        }
        menuItems.append(deleteMenuItem)
        
        return menuItems
    }
    
    func bind(_ viewModel: SearchNavBarViewModel) {
            
        viewModel.action
            .compactMap { $0 as? TemplatesListViewModelAction.SearchNavBarAction.Close }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                self.action.send(TemplatesListViewModelAction.RegularNavBar.RegularNavBarPresent())
            }
            .store(in: &bindings)
        
        viewModel.$searchText
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self] searchText in
                
                self.action.send(TemplatesListViewModelAction.Search(text: searchText))
            }
            .store(in: &bindings)
        
    }
}

struct NavigationBarButtonViewModel: Identifiable {
    
    let id: String = UUID().uuidString
    let title: String
    let icon: Image
    let action: () -> Void
    
    init(title: String = "", icon: Image = Image(""), action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}
 
extension NavigationBarView.ViewModel.ButtonItemViewModel {
    
    static func barcodeScanner(
        action: @escaping () -> Void
    ) -> NavigationBarView.ViewModel.ButtonItemViewModel {
        
        return .init(
            icon: .ic24BarcodeScanner2,
            action: action
        )
    }
}
