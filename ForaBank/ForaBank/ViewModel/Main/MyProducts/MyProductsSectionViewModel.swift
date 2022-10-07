//
//  MyProductsSectionViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.04.2022.
//

import Foundation
import SwiftUI
import Combine

extension MyProductsSectionViewModel {
    
    static let notAcivatedSectionId = "notAcivatedSectionId"
    static let blockedSectionId = "blockedSectionId"
}

class MyProductsSectionViewModel: ObservableObject, Identifiable {

    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var items: [MyProductsSectionItemViewModel]
    @Published var isCollapsed: Bool

    let id: String
    let title: String
    let isEnabled: Bool
    
    init(id: String,
         title: String,
         items: [MyProductsSectionItemViewModel],
         isCollapsed: Bool,
         isEnabled: Bool) {

        self.id = id
        self.title = title
        self.isCollapsed = isCollapsed
        self.isEnabled = isEnabled
        self.items = items
    }
    
    convenience init(productType: ProductType, items: [MyProductsSectionItemViewModel]) {
        
        self.init(id: productType.rawValue, title: productType.pluralName, items: items, isCollapsed: false, isEnabled: true)
    }
}

extension MyProductsSectionViewModel {

    func padding(_ model: MyProductsSectionItemViewModel) -> CGFloat {

        if items.first?.id == model.id {
            return 8
        }

        return 0
    }
}

extension MyProductsSectionViewModel {
    
    static let sample1 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Неактивированные продукты",
        items: [.sample1, .sample2, .sample3],
        isCollapsed: false,
        isEnabled: true
    )
    
    static let sample2 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Карты",
        items: [.sample4, .sample5],
        isCollapsed: false,
        isEnabled: true
    )
    
    static let sample3 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Вклады",
        items: [.sample6],
        isCollapsed: true,
        isEnabled: true
    )
    
    static let sample4 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Кредиты",
        items: [],
        isCollapsed: false,
        isEnabled: false
    )
    
    static let sample5 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Инвестиции",
        items: [],
        isCollapsed: false,
        isEnabled: false
    )
    
    static let sample6 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Страховка",
        items: [],
        isCollapsed: false,
        isEnabled: false
    )
}
