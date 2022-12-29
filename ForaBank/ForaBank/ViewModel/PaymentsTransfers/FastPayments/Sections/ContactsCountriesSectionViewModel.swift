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
            
            let countriesList = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
            self.items.value = Self.reduceCounry(countriesList: countriesList) { [weak self] country in
                
                { self?.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(countryId: country.id)) }
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
    }
}

//MARK: - Reducers

extension ContactsCountriesSectionViewModel {
    
    static func reduceCounry(countriesList: [CountryData], action: @escaping (CountryData) -> () -> Void) -> [ContactsItemViewModel] {
        
        countriesList
            .map({ ContactsCountryItemView.ViewModel(id: $0.id, icon: $0.svgImage?.image, name: $0.name, action: action($0)) })
            .sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
            .sorted(by: {$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending})
    }
    
    static func reduce(items: [ContactsItemViewModel], filter: String?) -> [ContactsItemViewModel] {
        
        guard let filter = filter else {
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
            
            let countryId: CountryData.ID
        }
    }
}
