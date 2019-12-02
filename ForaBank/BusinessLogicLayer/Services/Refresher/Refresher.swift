//
//  Refresher.swift
//  ForaBank
//
//  Created by Бойко Владимир on 08.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class Refresher<T: IRefreshing>: IRefresher {

    internal let interval: Double
    internal weak var target: T?

    init(target: T?, interval: Double) {
        self.interval = interval
        self.target = target
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] (timer) in
            self?.target?.refresh()
        }
    }
}
