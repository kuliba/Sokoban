//
//  ParameterViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

enum ParameterViewModel {
    
    case sticker(StickerViewModel)
    case tip(TipViewModel)
    case select(SelectViewModel)
    case product(ProductViewModel)
    case amount(AmountViewModel)
    case input(InputViewModel)
}
