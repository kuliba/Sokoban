//
//  PaymentsGroupViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 20.02.2023.
//

import Foundation
import Combine
import SwiftUI

class PaymentsGroupViewModel: Identifiable {
    
    let id: String
    let items: [PaymentsParameterViewModel]
    
    init(id: String = UUID().uuidString, items: [PaymentsParameterViewModel]) {
        
        self.id = id
        self.items = items
    }
}

final class PaymentsSpoilerGroupViewModel: PaymentsGroupViewModel, ObservableObject {
    
    @Published var isCollapsed: Bool
    let button: PaymentsSpoilerButtonView.ViewModel
    
    private var binding: AnyCancellable?
    
    init(id: String = UUID().uuidString, items: [PaymentsParameterViewModel], isCollapsed: Bool, button: PaymentsSpoilerButtonView.ViewModel = .init(title: "Дополнительно", isSelected: true)) {
        
        self.isCollapsed = isCollapsed
        self.button = button
        super.init(id: id, items: items)
        
        binding = button.$isSelected
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self] isSelected in
                
                withAnimation {
                    
                    self.isCollapsed = isSelected
                }
            }
    }
}

final class PaymentsContactGroupViewModel: PaymentsGroupViewModel, ObservableObject {
    
    @Published var isCollapsed: Bool
    var collapsedItem: PaymentsInfoView.ViewModel {
       
        let content = items.compactMap({ $0.value.current }).joined(separator: " ")
        return .init(icon: .ic24User, title: "Получатель", content: content, iconStyle: .small)
    }
    
    init(id: String = UUID().uuidString, items: [PaymentsParameterViewModel], isCollapsed: Bool) {
        
        self.isCollapsed = isCollapsed
        super.init(id: id, items: items)
    }
    
    convenience init(items: [PaymentsParameterViewModel]) {
        
        if items.compactMap({$0.value.current}).count > 0 {
            
            self.init(items: items, isCollapsed: true)
        } else {
            
            self.init(items: items, isCollapsed: false)
        }
    }
}

final class PaymentsInfoGroupViewModel: PaymentsGroupViewModel {}
