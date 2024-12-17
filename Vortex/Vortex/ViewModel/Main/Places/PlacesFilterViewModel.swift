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
    @Published var availableServicesIds: Set<ServiceOptionViewModel.ID>
    @Published var filter: AtmFilter
    
    private var bindings = Set<AnyCancellable>()

    init(categories: [CategoryOptionViewModel], services: [ServiceGroupViewModel], selectedCategoriesIds: Set<CategoryOptionViewModel.ID>, selectedServicesIds: Set<ServiceOptionViewModel.ID>, availableServicesIds: Set<ServiceOptionViewModel.ID>, filter: AtmFilter) {
        
        self.categories = categories
        self.services = services
        self.selectedCategoriesIds = selectedCategoriesIds
        self.selectedServicesIds = selectedServicesIds
        self.availableServicesIds = availableServicesIds
        self.filter = filter
    }
    
    init(atmCategories: [AtmData.Category], atmServices: [AtmServiceData], atmAvailableServices: [AtmData.Category: Set<AtmServiceData.ID>], filter: AtmFilter) {
        
        self.categories = []
        self.services = []
        self.selectedServicesIds = []
        self.selectedCategoriesIds = []
        self.availableServicesIds = []
        self.filter = .init(categories: [], services: [])
        
        self.categories = atmCategories.map({ category in
            
            CategoryOptionViewModel(category: category, availableServicesIds: atmAvailableServices[category], action: { [weak self] optionId in self?.action.send(PlacesFilterViewModelAction.ToggleCategoryOption(id: optionId))})
        })
        
        var serviceGroups = [ServiceGroupViewModel]()
        for type in AtmServiceData.Kind.allCases {
            
            let typeAtmServices = atmServices.filter({ $0.type == type })
            let servicesOptions = typeAtmServices.map { service in
                
                ServiceOptionViewModel(service: service, action: { [weak self] optionId in self?.action.send(PlacesFilterViewModelAction.ToggleServiceOption(id: optionId)) })
            }
            
            let servicesGroup = ServiceGroupViewModel(title: type.name, options: servicesOptions)
            serviceGroups.append(servicesGroup)
        }

        self.services = serviceGroups
        self.selectedCategoriesIds = Set(filter.categories.map{ $0.rawValue })
        self.selectedServicesIds = filter.services
        
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
            .sink {[unowned self] selectedCategoriesIds in
               
                let selectedCategories = categories.filter({ selectedCategoriesIds.contains($0.id)})
                availableServicesIds = selectedCategories.reduce(Set<ServiceOptionViewModel.ID>(), { partialResult, category in
                    
                    return partialResult.union(category.availableServicesIds)
                })
                
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
        let actualSelectedServicesIds = selectedServicesIds.intersection(availableServicesIds)
        self.filter = AtmFilter(categories: selectedCategories, services: actualSelectedServicesIds)
    }
}

//MARK: - Types

extension PlacesFilterViewModel {
    
    struct CategoryOptionViewModel: Identifiable {

        var id: Int { category.rawValue }
        let category: AtmData.Category
        let icon: Image
        let name: String
        let availableServicesIds: Set<ServiceOptionViewModel.ID>
        let action: (CategoryOptionViewModel.ID) -> Void
        
        init(category: AtmData.Category, availableServicesIds: Set<ServiceOptionViewModel.ID>?, action: @escaping (CategoryOptionViewModel.ID) -> Void) {
            
            self.category = category
            self.icon = category.icon
            self.name = category.name
            self.availableServicesIds = availableServicesIds ?? []
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
    
    static let sample = PlacesFilterViewModel(atmCategories: [.office, .atm, .terminal], atmServices: [.init(id: 1, name: "Без выходных", type: .service), .init(id: 2, name: "Вклады", type: .service), .init(id: 3, name: "Потреб. кредиты", type: .service), .init(id: 4, name: "Ипотека", type: .service), .init(id: 5, name: "Выдача наличных", type: .service), .init(id: 6, name: "Прием наличных", type: .other), .init(id: 7, name: "Денежные переводы", type: .other), .init(id: 8, name: "Оплата услуг", type: .other), .init(id: 9, name: "Аккредитивы", type: .other), .init(id: 10, name: "регистрация в ЕБС", type: .other), .init(id: 11, name: "Обслуживание юридических лиц", type: .other)], atmAvailableServices: [:], filter: .initial)
}
