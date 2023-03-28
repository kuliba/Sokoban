//
//  ContactsCountrySectionCollapsableViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import Combine
import SwiftUI

class ContactsCountriesSectionViewModel: ContactsSectionCollapsableViewModel {
    
    override var type: ContactsSectionViewModel.Kind { .countries }
    @Published var visible: [ContactsItemViewModel]
    let filter: CurrentValueSubject<String?, Never>
    
    private let items: CurrentValueSubject<[ContactsItemViewModel], Never>

    init(header: ContactsSectionHeaderView.ViewModel, isCollapsed: Bool, mode: Mode, visible: [ContactsItemViewModel], items: [ContactsItemViewModel], filter: String? = nil, model: Model) {
        
        self.visible = visible
        self.filter = .init(filter)
        self.items = .init(items)
        super.init(header: header, isCollapsed: isCollapsed, mode: mode, model: model)
    }
    
    convenience init(_ model: Model, mode: Mode) {
        
        self.init(header: .init(kind: .country), isCollapsed: true, mode: mode, visible: [], items: [], model: model)
        
        Task.detached(priority: .userInitiated) {
            
            var countries: [CountryWithServiceData] = []
            
            switch mode {
            case .fastPayment:
                 countries = model.countriesListWithSevice.value.filter({$0.id == "AM"})
                
            case .select:
                
                countries = model.countriesListWithSevice.value
            }
            
            let imageIds = countries.compactMap { $0.md5hash }
            
            let containsAll = imageIds.filter { id in
                
                if model.images.value.contains(where: {$0.key == id}) {
                    
                    return false
                } else {
                    
                    return true
                }
            }
            
            if containsAll.isEmpty == false {
                
                self.model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: containsAll))
            }
            
            self.items.value = Self.reduceCounryWithService(model: self.model, countriesList: countries) { [weak self] country in
                
                {
                    self?.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: .direct(phone: nil, countryId: country.id)))
                }
            }
        }
    }
    
    override func bind() {
        super.bind()
        
        items
            .combineLatest(filter)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                let items = data.0
                let filter = data.1
                
                if items.isEmpty == false {
                    
                    withAnimation {
                        
                        visible = Self.reduce(items: items, filter: filter)
                    }
                    
                } else {
                    
                    withAnimation {
                        
                        visible = Array(repeating: ContactsPlaceholderItemView.ViewModel(style: .country), count: 8)
                    }
                }
                
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Dictionary.DownloadImages.Response:
                    switch payload.result {
                    case .success(_):
                        
                        var countryList: [ContactsCountryItemView.ViewModel] = []
                        
                        for country in self.model.countriesListWithSevice.value {
                        
                            let icon = self.model.images.value.first(where: {$0.key == country.md5hash})?.value
                            countryList.append(.init(id: country.code, icon: icon, name: country.name.capitalized, action: {
                                
                                self.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(source: .direct(phone: nil, countryId: country.id)))
                            }))
                        }
                        
                        self.items.value = countryList.sorted(by: {$0.name.lowercased() < $1.name.lowercased()}).sorted(by: {$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending})
                        
                    case let .failure(error):
                        print(error) //TODO: send error action
                    }
                default:
                    break
                }
            }.store(in: &bindings)
    }
}

//MARK: - Reducers

extension ContactsCountriesSectionViewModel {
    
    static func reduceCounryWithService(model: Model, countriesList: [CountryWithServiceData], action: @escaping (CountryWithServiceData) -> () -> Void) -> [ContactsItemViewModel] {

        var items: [ContactsCountryItemView.ViewModel] = []
        
        for country in countriesList {
            
            let icon = model.images.value.first(where: {$0.key == country.md5hash})?.value
            items.append(ContactsCountryItemView.ViewModel.init(id: country.id, icon: icon, name: country.name.capitalized, action: action(country)))
        }
        
        let sortedItems = items.sorted(by: {$0.name.lowercased() < $1.name.lowercased()}).sorted(by: {$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending})
        
        return sortedItems
    }
    
    static func reduce(items: [ContactsItemViewModel], filter: String?) -> [ContactsItemViewModel] {
        
        guard let filter = filter, filter != "" else {
            return items
        }
        
        return items.compactMap({ $0 as? ContactsCountryItemView.ViewModel })
            .filter({ $0.name.localizedStandardContains(filter) })
    }
}

//MARK: - Action

extension ContactsSectionViewModelAction {
    
    enum Countries {
    
        struct ItemDidTapped: Action {
            
            let source: Payments.Operation.Source
        }
    }
}
