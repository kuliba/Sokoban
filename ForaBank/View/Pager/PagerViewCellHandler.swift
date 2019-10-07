//
//  PagerViewCellConfigurator.swift
//  ForaBank
//
//  Created by Бойко Владимир on 02/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import FSPagerView

protocol IConfigurableCell {
    associatedtype ICellProvider
    func configure(provider: ICellProvider)
}

protocol ICellConfigurator {
    static var reuseId: String { get }
    var item: IPresentationModel? { get }
    func configure(cell: UIView)
}

class PagerViewCellHandler<CellType: IConfigurableCell, ProviderType: ICellProvider>: ICellConfigurator where CellType.ICellProvider == ICellProvider, CellType: FSPagerViewCell {
    
    static var reuseId: String { return String(describing: CellType.self) }
   
    let provider: ICellProvider
    var item: IPresentationModel? {
        get {
            return provider.currentValue
        }
    }

    init(provider: ICellProvider) {
        self.provider = provider
        
    }

    func configure(cell: UIView) {
        (cell as! CellType).configure(provider: provider)
    }
}
