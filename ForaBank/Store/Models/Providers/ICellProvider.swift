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

protocol ICellProvider {
    var isLoading: Bool { get }
    var currentValue: IPresentationModel? { get set }
    func getData(completion: @escaping (_ data: [IPresentationModel]) -> ())
}
