//
//  PagerViewCellConfigurator.swift
//  ForaBank
//
//  Created by Бойко Владимир on 02/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import FSPagerView

protocol ICellConfigurator: NSObject {
    static var reuseId: String { get }
    var delegate: ICellConfiguratorDelegate? { get set }
    func configure(cell: UIView)
}

protocol ICellConfiguratorDelegate: class {
    func didReciveNewValue(value: Any, from configurator: ICellConfigurator)
}

class PagerViewCellHandler<CellType: IConfigurableCell, ProviderType: ICellProvider>: NSObject, ICellConfigurator where CellType.ICellProvider == ICellProvider, CellType: FSPagerViewCell {

    static var reuseId: String { return String(describing: CellType.self) }

    let provider: ICellProvider

    weak var delegate: ICellConfiguratorDelegate?

    init(provider: ICellProvider, delegate: ICellConfiguratorDelegate) {
        self.provider = provider
        self.delegate = delegate
    }

    func configure(cell: UIView) {
        guard let cell = cell as? CellType else { return }
        cell.configure(provider: provider, delegate: self)
    }
}

extension PagerViewCellHandler: ConfigurableCellDelegate {
    func didInputPaymentValue(value: Any) {
        delegate?.didReciveNewValue(value: value, from: self)
    }
}
