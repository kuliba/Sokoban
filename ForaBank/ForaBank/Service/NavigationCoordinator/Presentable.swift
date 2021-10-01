//
//  Presentable.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.09.2021.
//

import UIKit

public protocol Presentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: Presentable {
    public func toPresentable() -> UIViewController {
        return self
    }
}
