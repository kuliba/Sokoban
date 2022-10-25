//
//  ContactsCollapsableSectionViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import Combine
import SwiftUI

class CollapsableSectionViewModel: ObservableObject, Hashable, Equatable {
    
    let id = UUID()
    @Published var header: HeaderViewModel
    @Published var isCollapsed: Bool
    @Published var items: [ItemViewModel]
    
    private var bindings = Set<AnyCancellable>()
    
    init(header: HeaderViewModel, isCollapsed: Bool = false, items: [ItemViewModel]) {
        
        self.isCollapsed = isCollapsed
        self.header = header
        self.items = items
        
        bind()
    }
    
    func bind() {
        
        header.$isCollapsed
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { isCollapsed in
                
                self.isCollapsed.toggle()
                
            }.store(in: &bindings)
    }
    
    class HeaderViewModel: ObservableObject {
        
        @Published var icon: Image
        var title: String
        @Published var isCollapsed: Bool
        @Published var searchButton: ButtonViewModel?
        @Published var toggleButton: ButtonViewModel
        
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
                let searchButton = ButtonViewModel(icon: .ic24Search, action: {})
                
                self.init(icon: icon, title: title, searchButton: searchButton, toggleButton: toggleButton)
                
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
    
    class ItemViewModel: Hashable {
        
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
            lhs.title == rhs.title
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(title)
        }
    }
    
    enum Kind {
        case banks, country
    }
}

extension CollapsableSectionViewModel {
    
    static func == (lhs: CollapsableSectionViewModel, rhs: CollapsableSectionViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
    }
}
