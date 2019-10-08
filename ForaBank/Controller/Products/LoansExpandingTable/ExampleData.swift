//
//  ExampleData.swift
//  ios-swift-collapsible-table-section
//
//  Created by Yong Su on 8/1/17.
//  Copyright © 2017 Yong Su. All rights reserved.
//

import Foundation

//
// MARK: - Section Data Structure
//
public struct Item {
    var name: String
    var detail: String
    
    public init(name: String, detail: String) {
        self.name = name
        self.detail = detail
    }
}

public struct Section {
    var name: String
    var items: [Item]
    var collapsed: Bool
    
    public init(name: String, items: [Item], collapsed: Bool = true) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}

public var sectionsData: [Section] = [
    Section(name: "02 Ноября 2019", items: [
        Item(name: "Оплата за кредит ", detail: "3590 Р"),
    ]),
    Section(name: "02 Декабря 2019", items: [
      Item(name: "Оплата за кредит ", detail: "3590 Р"),
    ]),
    Section(name: "02 Января 2020", items: [
      Item(name: "Оплата за кредит ", detail: "3590 Р"),
    ]),
    Section(name: "02 Февраля 2020", items: [
         Item(name: "Оплата за кредит ", detail: "3590 Р"),
       ]),
    Section(name: "02 Марта 2020", items: [
         Item(name: "Оплата за кредит ", detail: "3590 Р"),
       ]),
    Section(name: "02 Апреля 2020", items: [
         Item(name: "Оплата за кредит ", detail: "3590 Р"),
       ])
]

