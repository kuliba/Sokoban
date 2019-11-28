//
//  PagerViewCellConfigurator.swift
//  ForaBank
//
//  Created by Бойко Владимир on 02/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import FSPagerView

protocol ICellConfigurator {
    static var reuseId: String { get }
    var item: IPresentationModel? { get }
    func configure(cell: UIView)
}

class PagerViewCellHandler<CellType: IConfigurableCell, ProviderType: ICellProvider>: ICellConfigurator where CellType.ICellProvider == ICellProvider, CellType: FSPagerViewCell {

    static var reuseId: String { return String(describing: CellType.self) }

    let provider: ICellProvider

    weak var cellDelegate: ConfigurableCellDelegate?
    var item: IPresentationModel? {
        get {
            return provider.currentValue
        }
    }

    init(provider: ICellProvider, delegate: ConfigurableCellDelegate) {
        self.provider = provider
        cellDelegate = delegate
    }

    func configure(cell: UIView) {
        guard let cell = cell as? CellType else { return }
        cell.configure(provider: provider)
        cell.delegate = cellDelegate
    }
}
