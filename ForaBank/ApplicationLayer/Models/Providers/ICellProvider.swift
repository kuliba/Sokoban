//
//  ICellProvider.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IPresentationModel {
}

extension String: IPresentationModel {
}

protocol ICellProvider: class {
    var isLoading: Bool { get }
    var currentValue: IPresentationModel? { get set }

    func getData(completion: @escaping (_ data: [IPresentationModel]) -> ())
}

protocol ITextInputCellProvider: ICellProvider, UITextFieldDelegate {
    var iconName: String { get }
    var placeholder: String { get }
    var charactersMaxCount: Int { get }
    var textField: String{get}
    
    func formatted(stringToFormat string: String) -> String
}
