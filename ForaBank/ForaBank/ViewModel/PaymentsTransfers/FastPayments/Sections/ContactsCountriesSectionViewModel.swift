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
    
    private var items: [ContactsItemViewModel]

    init(header: ContactsSectionHeaderView.ViewModel, isCollapsed: Bool, mode: Mode, visible: [ContactsItemViewModel], items: [ContactsItemViewModel], filter: String? = nil, model: Model) {
        
        self.visible = visible
        self.filter = .init(filter)
        self.items = items
        super.init(header: header, isCollapsed: isCollapsed, mode: mode, model: model)
    }
    
    convenience init(_ model: Model, mode: Mode) {
        
        let placeholders = Array(repeating: ContactsPlaceholderItemView.ViewModel(style: .country), count: 8)
        self.init(header: .init(kind: .country), isCollapsed: true, mode: mode, visible: placeholders, items: [], model: model)
        
        let countriesList = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
        
        withAnimation {
            
            items = Self.reduceCounry(countriesList: countriesList) { [weak self] country in
                
                { self?.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(countryId: country.id)) }
            }
        }
    }
    
    override func bind() {
        super.bind()
        
        filter
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] filter in
                
                withAnimation {
                    
                    visible = Self.reduce(items: items, filter: filter)
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
