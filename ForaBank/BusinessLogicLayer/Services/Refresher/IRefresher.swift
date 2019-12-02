//
//  IRefresher.swift
//  ForaBank
//
//  Created by MacAdmin on 02.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IRefreshing: class {
    func refresh()
}

protocol IRefresher {
    associatedtype RefreshTarget: IRefreshing

    var interval: Double { get }
    var target: RefreshTarget? { get }
}
