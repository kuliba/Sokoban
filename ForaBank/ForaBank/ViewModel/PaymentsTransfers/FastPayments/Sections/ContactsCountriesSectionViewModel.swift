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
    //TODO: visible
    let filter: CurrentValueSubject<String?, Never>
    @Published var items: [ContactsItemViewModel]
    
    
    init(header: ContactsSectionHeaderView.ViewModel, isCollapsed: Bool, mode: Mode, items: [ContactsItemViewModel], filter: String? = nil, model: Model) {
        
        self.items = items
        self.filter = .init(filter)
        super.init(header: header, isCollapsed: isCollapsed, mode: mode, model: model)
    }
    
    convenience init(_ model: Model, mode: Mode) {
        
        let placeholders = Array(repeating: ContactsPlaceholderItemView.ViewModel(style: .country), count: 8)
        self.init(header: .init(kind: .country), isCollapsed: true, mode: mode, items: placeholders, model: model)
        
        let countriesList = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
        
        withAnimation {
            
            items = Self.reduceCounry(countriesList: countriesList) { [weak self] country in
                
                { self?.action.send(ContactsSectionViewModelAction.Countries.ItemDidTapped(country: country)) }
            }
        }
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    static func reduceCounry(countriesList: [CountryData], action: @escaping (CountryData) -> () -> Void) -> [ContactsItemViewModel] {
        
        countriesList
            .map({ ContactsCountryItemView.ViewModel(id: $0.id, icon: $0.svgImage?.image, name: $0.name, action: action($0)) })
            .sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
            .sorted(by: {$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending})
    }
}

//MARK: - Action

extension ContactsSectionViewModelAction {
    
    enum Countries {
    
        struct ItemDidTapped: Action {
            
            let country: CountryData
        }
    }
}
