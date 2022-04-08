//
//  PlacesFilterViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 06.04.2022.
//

import Foundation
import SwiftUI
import Combine

class PlacesFilterViewModel: ObservableObject, Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let id = UUID().uuidString
    let title = "Фильтры"
    let categoriesSubtitle = "На карте"
    @Published var categories: [CategoryOptionViewModel]
    @Published var services: [ServiceGroupViewModel]
    @Published var selectedCategoriesIds: Set<CategoryOptionViewModel.ID>
    @Published var selectedServicesIds: Set<ServiceOptionViewModel.ID>
    @Published var filter: AtmFilter
    
    private var bindings = Set<AnyCancellable>()

    init(categories: [CategoryOptionViewModel], services: [ServiceGroupViewModel], selectedCategoriesIds: Set<CategoryOptionViewModel.ID>, selectedServicesIds: Set<ServiceOptionViewModel.ID>, filter: AtmFilter) {
        
        self.categories = categories
        self.services = services
        self.selectedCategoriesIds = selectedCategoriesIds
        self.selectedServicesIds = selectedServicesIds
        self.filter = filter
    }
    
    init(atmCategories: [AtmData.Category], atmServices: [AtmServiceData], filter: AtmFilter?) {
        
        self.categories = []
        self.services = []
        self.selectedServicesIds = []
        self.selectedCategoriesIds = []
        self.filter = .init(categories: [], services: [])
        
        self.categories = atmCategories.map({ category in
            
            CategoryOptionViewModel(category: category, action: { [weak self] optionId in self?.action.send(PlacesFilterViewModelAction.ToggleCategoryOption(id: optionId))})
        })
        
        let servicesOptions = atmServices.map { service in
            
            ServiceOptionViewModel(service: service, action: { [weak self] optionId in self?.action.send(PlacesFilterViewModelAction.ToggleServiceOption(id: optionId)) })
        }
        
        let servicesGroup = ServiceGroupViewModel(title: "Услуги", options: servicesOptions)
        self.services = [servicesGroup]
        
        if let filter = filter {
            
            self.selectedCategoriesIds = Set(filter.categories.map{ $0.rawValue })
            self.selectedServicesIds = filter.services
            
        } else {
            
            self.selectedCategoriesIds = Set(categories.map{ $0.id })
            self.selectedServicesIds = Set(services.flatMap({ $0.options }).map({ $0.id }))
        }
        
        bind()
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] action in
                
                switch action {
                case let payload as PlacesFilterViewModelAction.ToggleCategoryOption:
                    if selectedCategoriesIds.contains(payload.id) {
                        
                        guard selectedCategoriesIds.count > 1 else {
                            return
                        }
                        selectedCategoriesIds.remove(payload.id)
                        
                    } else {
                        
                        selectedCategoriesIds.insert(payload.id)
                    }
                    
                case let payload as PlacesFilterViewModelAction.ToggleServiceOption:
                    if selectedServicesIds.contains(payload.id) {
                        
                        guard selectedServicesIds.count > 1 else {
                            return
                        }
                        
                        selectedServicesIds.remove(payload.id)
                    } else {
                        
                        selectedServicesIds.insert(payload.id)
                    }
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
        $selectedCategoriesIds
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] _ in
               
                updateFilter()
               
            }.store(in: &bindings)
        
        $selectedServicesIds
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] _ in
               
                updateFilter()
               
            }.store(in: &bindings)
    }
    
    private func updateFilter() {
        
        let selectedCategories = Set(selectedCategoriesIds.compactMap{ AtmData.Category(rawValue: $0) })
        self.filter = AtmFilter(categories: selectedCategories, services: selectedServicesIds)
    }
}

//MARK: - Types

extension PlacesFilterViewModel {
    
    struct CategoryOptionViewModel: Identifiable {

        var id: Int { category.rawValue }
        let category: AtmData.Category
        let icon: Image
        let name: String
        let action: (CategoryOptionViewModel.ID) -> Void
        
        init(category: AtmData.Category, action: @escaping (CategoryOptionViewModel.ID) -> Void) {
            
            self.category = category
            self.icon = category.icon
            self.name = category.name
            self.action = action
        }
    }
    
    struct ServiceGroupViewModel: Identifiable {
        
        let id = UUID()
        let title: String
        let options: [ServiceOptionViewModel]
    }
    
    struct ServiceOptionViewModel: Identifiable, Hashable {
        
        var id: AtmServiceData.ID
        let name: String
        let action: (ServiceOptionViewModel.ID) -> Void
        
        internal init(service: AtmServiceData, action: @escaping (ServiceOptionViewModel.ID) -> Void) {
            
            self.id = service.id
            self.name = service.name
            self.action = action
        }
        
        /// Hashable
    
        static func == (lhs: PlacesFilterViewModel.ServiceOptionViewModel, rhs: PlacesFilterViewModel.ServiceOptionViewModel) -> Bool {
            
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(id)
        }
    }
}

//MARK: - Action

enum PlacesFilterViewModelAction {

    struct ToggleCategoryOption: Action {
        
        let id: PlacesFilterViewModel.CategoryOptionViewModel.ID
    }
    
    struct ToggleServiceOption: Action {
        
        let id: PlacesFilterViewModel.ServiceOptionViewModel.ID
    }
}

//MARK: - Sample Data

extension PlacesFilterViewModel {
    
    static let sample = PlacesFilterViewModel(atmCategories: [.office, .atm, .terminal], atmServices: [.init(id: 1, name: "Без выходных"), .init(id: 2, name: "Вклады"), .init(id: 3, name: "Потреб. кредиты"), .init(id: 4, name: "Ипотека"), .init(id: 5, name: "Выдача наличных"), .init(id: 6, name: "Прием наличных"), .init(id: 7, name: "Денежные переводы"), .init(id: 8, name: "Оплата услуг"), .init(id: 9, name: "Аккредитивы"), .init(id: 10, name: "регистрация в ЕБС"), .init(id: 11, name: "Обслуживание юридических лиц")], filter: nil)
}
