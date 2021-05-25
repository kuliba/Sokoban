//
//  PrepareExternalModel.swift
//  ForaBank
//
//  Created by Дмитрий on 01.02.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

// MARK: - PrepareExternal
struct PrepareExternal: Codable {
    var data: DataClassExtenal?
    var errorMessage, result: String?
}

// MARK: - DataClass
struct DataClassExtenal: Codable {
}
