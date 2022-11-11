//
//  ContactsCountrySectionCollapsableViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import SwiftUI

class ContactsCountrySectionViewModel: ContactsSectionCollapsableViewModel {
    
    convenience init(countriesList: [CountryData], model: Model) {
        
        self.init(header: .init(kind: .country), items: [], model: model)
        
        let items = Self.reduceCounry(countriesList: countriesList) { [weak self] country in
            
            { self?.action.send(ContactsCountrySectionViewModelAction.CountryDidTapped(country: country)) }
        }
        
        self.items = items
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    static func reduceCounry(countriesList: [CountryData], action: @escaping (CountryData) -> () -> Void) -> [ContactsSectionCollapsableViewModel.ItemViewModel] {
        
        var country = [ContactsSectionCollapsableViewModel.ItemViewModel]()
        
        country = countriesList.map({ContactsSectionCollapsableViewModel.ItemViewModel(title: $0.name, image: $0.svgImage?.image, bankType: nil, action: action($0))})
        country = country.sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
        country = country.sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
        
        return country
    }
}

struct ContactsCountrySectionViewModelAction {
    
    struct CountryDidTapped: Action {
        
        let country: CountryData
    }
}
