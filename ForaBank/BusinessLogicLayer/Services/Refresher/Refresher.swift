//
//  Refresher.swift
//  ForaBank
//
//  Created by Бойко Владимир on 08.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class Refresher<T: IRefreshing>: IRefresher {
    
    internal weak var target: T?
    private var timer: Timer?
    
    init(target: T?) {
        self.target = target
    }
    
    public func launchTimer(repeats: Bool, timeInterval: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { [weak self] (timer) in
            self?.target?.refresh()
        }
    }
    
    func invalidateTimer() {
        timer?.invalidate()
    }
}
