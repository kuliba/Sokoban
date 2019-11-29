//
//  IConfigurableCell.swift
//  ForaBank
//
//  Created by Бойко Владимир on 28.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IConfigurableCell: class {
    associatedtype ICellProvider

    var delegate: ConfigurableCellDelegate? { get set }
    func configure(provider: ICellProvider, delegate: ConfigurableCellDelegate)
}

protocol ConfigurableCellDelegate: class {
    func didInputPaymentValue(value: Any)
}
