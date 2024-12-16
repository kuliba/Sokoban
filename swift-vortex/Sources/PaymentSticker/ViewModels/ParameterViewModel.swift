//
//  ParameterViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public enum ParameterViewModel {
    
    case sticker(StickerViewModel)
    case tip(TipViewModel)
    case select(SelectViewModel)
    case product(ProductStateViewModel)
    case amount(AmountViewModel)
    case input(value: String?, title: String, warning: String?)
}
