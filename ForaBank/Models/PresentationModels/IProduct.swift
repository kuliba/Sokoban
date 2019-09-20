//
//  IProduct.swift
//  ForaBank
//
//  Created by Бойко Владимир on 20/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IProduct {
    var name: String { get }
    var id: Double { get }
    var balance: Double { get }
    var number: String { get }
}
