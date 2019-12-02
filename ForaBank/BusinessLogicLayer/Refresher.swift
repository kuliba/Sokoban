//
//  Refresher.swift
//  ForaBank
//
//  Created by Бойко Владимир on 08.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IRefreshing {
    func refresh()
}

protocol IRefresher {
    associatedtype RefreshTarget: IRefreshing

    var interval: Double { get }
    var target: RefreshTarget { get }
}

struct Refresher<T: IRefreshing>: IRefresher {

    internal let interval: Double
    internal let target: T

    init(target: T, interval: Double) {
        self.interval = interval
        self.target = target
    }
}
