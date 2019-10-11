//
//  IPickerItem.swift
//  ForaBank
//
//  Created by Бойко Владимир on 26/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

enum PickerItemType {
    case paymentOption
    case plain
}

protocol IPickerItem {
    var itemType: PickerItemType { get }
    var title: String { get }
    var subTitle: String { get }
    var value: Double { get }
}
