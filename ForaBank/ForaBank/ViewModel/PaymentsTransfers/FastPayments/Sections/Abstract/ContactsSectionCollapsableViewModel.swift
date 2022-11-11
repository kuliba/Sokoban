//
//  ContactsSectionCollapsableViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import Combine
import SwiftUI

class ContactsSectionCollapsableViewModel: ContactsSectionViewModel, ObservableObject {

    @Published var header: HeaderViewModel
    @Published var isCollapsed: Bool
    @Published var items: [ItemViewModel]
    
    init(header: HeaderViewModel, isCollapsed: Bool = false, items: [ItemViewModel], model: Model) {
        
        self.isCollapsed = isCollapsed
        self.header = header
        self.items = items
        
        super.init(model: model)
        
        bind()
    }
    
    func bind() {
        
        header.$isCollapsed
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCollapsed in
                
                self?.isCollapsed.toggle()
                
            }.store(in: &bindings)
    }
    

}

//MARK: - Types

extension ContactsSectionCollapsableViewModel {
    
    class HeaderViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()

        @Published var icon: Image
        var title: String
        @Published var isCollapsed: Bool
        @Published var searchButton: ButtonViewModel?
        @Published var toggleButton: ButtonViewModel
        
        enum Kind {
            
            case banks, country
        }
        
        init(icon: Image, isCollapsed: Bool = false, title: String, searchButton: ButtonViewModel? = nil, toggleButton: ButtonViewModel) {
            
            self.icon = icon
            self.isCollapsed = isCollapsed
            self.title = title
            self.searchButton = searchButton
            self.toggleButton = toggleButton
        }
        
        convenience init(kind: Kind) {
            
            switch kind {
                
            case .banks:
                let icon: Image = .ic24SBP
                let title = "В другой банк"
                let toggleButton = ButtonViewModel(icon: .ic24ChevronUp, action: {})
                
                self.init(icon: icon, title: title, searchButton: nil, toggleButton: toggleButton)
                self.searchButton = ButtonViewModel(icon: .ic24Search, action: { [weak self] in
                    
                    self?.action.send(HeaderViewModelAction.SearchDidTapped())
                })
                
            case .country:
                let icon: Image = .ic24Abroad
                let title = "Переводы за рубеж"
                let button = ButtonViewModel(icon: .ic24ChevronUp, action: {})
                
                self.init(icon: icon, title: title, toggleButton: button)
            }
        }
        
        struct ButtonViewModel {
            
            var icon: Image
            var action: () -> Void
        }
    }
    
    class ItemViewModel: Hashable, Identifiable {
        
        let id = UUID()
        let title: String
        let image: Image?
        let bankType: BankType?
        let action: () -> Void
        
        init(title: String, image: Image?, bankType: BankType?, action: @escaping () -> Void) {
            
            self.title = title
            self.image = image
            self.bankType = bankType
            self.action = action
        }
        
        static func == (lhs: ItemViewModel, rhs: ItemViewModel) -> Bool {
            lhs.id == rhs.id && lhs.title == rhs.title
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(id)
            hasher.combine(title)
        }
    }
}



struct HeaderViewModelAction {
    
    struct SearchDidTapped: Action {}
}
