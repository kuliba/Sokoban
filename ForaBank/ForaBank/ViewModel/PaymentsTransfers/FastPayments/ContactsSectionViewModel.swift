//
//  ContactsSectionViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import Combine
import SwiftUI

class ContactsSectionViewModel: ObservableObject, Hashable, Equatable, Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
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
            .sink { [weak self] isCollapsed in
                
                self?.isCollapsed.toggle()
                
            }.store(in: &bindings)
    }
    
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

extension ContactsSectionViewModel {
    
    static func == (lhs: ContactsSectionViewModel, rhs: ContactsSectionViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
    }
}

struct HeaderViewModelAction {
    
    struct SearchDidTapped: Action {}
}
