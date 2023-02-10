//
//  ClientInformViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 31.01.2023.
//

import SwiftUI
import Combine

class ClientInformViewModel: ObservableObject {

    let items: [ClientInformItemViewModel]
    let title: String
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    init(model: Model, title: String = "Технические работы", items: [ClientInformItemViewModel]) {

        self.model = model
        self.title = title
        self.items = items
    }
    
    convenience init?(model: Model, itemsData: [String]) {
        
        let icon = Image.ic24Clock
        let items = Self.reduce(itemsData: itemsData, itemIcon: icon)
        
        self.init(model: model, items: items)
    }
    
    struct ClientInformItemViewModel: Identifiable {
        
        let id: String
        let icon: Image
        let text: String
    }

}

// MARK: - Reducer
extension ClientInformViewModel {

    static func reduce(itemsData: [String], itemIcon: Image) -> [ClientInformItemViewModel] {

        var items = [ClientInformItemViewModel]()
        for (index, itemData) in itemsData.enumerated() {
            items.append(.init(id: "auth\(index)", icon: itemIcon, text: itemData))
        }
        return items
    }
}

//MARK: - Preview Content

extension ClientInformViewModel {

    static let sampleItems: [ClientInformItemViewModel] =
    [.init(id: "auth1",
           icon: .ic24Clock,
           text: "Наблюдаются временные сложности в работе переводов по номеру телефону (СБП)."),
     .init(id: "auth2",
           icon: .ic24Clock,
           text: "В настоящий момент ведутся плановые технические работы. Ориентировочный срок окончания 15:00 по МСК")
    ]
    
    static let sampleItemsMax: [ClientInformItemViewModel] = {
        
        var items = ClientInformViewModel.sampleItems
        for i in (3...13) {
            items.append(.init(id: "auth\(i)",
                               icon: .ic24Clock,
                               text: "Наблюдаются временные сложности в работе переводов по номеру телефону \(i)"))
        }
        
        return items
    }()
    
    static let sampleItemsShort: [ClientInformItemViewModel] = {
        
        var items = [ClientInformItemViewModel]()
        for i in (3...13) {
            items.append(.init(id: "auth\(i)",
                               icon: .ic24Clock,
                               text: "Наблюдаются сложности \(i)"))
        }
        
        return items
    }()
}
