//
//  MyProductsSectionViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.04.2022.
//

import Foundation
import SwiftUI
import Combine

class MyProductsSectionViewModel: ObservableObject, Identifiable {

    @Published var items: [MyProductsSectionItemViewModel]
    @Published var isCollapsed: Bool

    let id: String
    let title: String
    let isEnabled: Bool
    
    init(title: String,
         items: [MyProductsSectionItemViewModel],
         isCollapsed: Bool,
         isEnabled: Bool) {

        id = UUID().uuidString
        self.title = title
        self.isCollapsed = isCollapsed
        self.isEnabled = isEnabled
        self.items = items
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
        title: "Неактивированные продукты",
        items: [.sample1, .sample2, .sample3],
        isCollapsed: false,
        isEnabled: true
    )
    
    static let sample2 = MyProductsSectionViewModel(
        title: "Карты",
        items: [.sample4, .sample5],
        isCollapsed: false,
        isEnabled: true
    )
    
    static let sample3 = MyProductsSectionViewModel(
        title: "Вклады",
        items: [.sample6],
        isCollapsed: true,
        isEnabled: true
    )
    
    static let sample4 = MyProductsSectionViewModel(
        title: "Кредиты",
        items: [],
        isCollapsed: false,
        isEnabled: false
    )
    
    static let sample5 = MyProductsSectionViewModel(
        title: "Инвестиции",
        items: [],
        isCollapsed: false,
        isEnabled: false
    )
    
    static let sample6 = MyProductsSectionViewModel(
        title: "Страховка",
        items: [],
        isCollapsed: false,
        isEnabled: false
    )
}
