//
//  ContactsCountrySectionCollapsableViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation

class ContactsCountrySectionViewModel: CollapsableSectionViewModel {
    
    override init(header: CollapsableSectionViewModel.HeaderViewModel, isCollapsed: Bool = false, items: [CollapsableSectionViewModel.ItemViewModel]) {
        
        super.init(header: header, items: items)
    }
    
    convenience init(countriesList: [CountryData]) {
        
        self.init(header: .init(kind: .country), items: [])
        
        let items = Self.reduceCounry(countriesList: countriesList) { [weak self] countryId in
            
            { self?.action.send(ContactsCountrySectionViewModelAction.CountryDidTapped(countryId: countryId)) }
        }
        
        self.items = items
    }
    
    static func reduceCounry(countriesList: [CountryData], action: @escaping (CountryData.ID) -> () -> Void) -> [CollapsableSectionViewModel.ItemViewModel] {
        
        var country = [CollapsableSectionViewModel.ItemViewModel]()
        
        country = countriesList.map({CollapsableSectionViewModel.ItemViewModel(title: $0.name, image: $0.svgImage?.image, bankType: nil, action: action($0.id))})
        country = country.sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
        country = country.sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
        
        return country
    }
}

struct ContactsCountrySectionViewModelAction {
    
    struct CountryDidTapped: Action {
        
        let countryId: CountryData.ID
    }
}
