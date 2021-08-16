//
//  GKHCellProtocol.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.08.2021.
//

import Foundation

///AdaptedCellViewModelProtocol служит лишь для полиморфизма подтипов наших viewModels для ячеек
protocol AdaptedCellViewModelProtocol { }
/// Протокол описывает интерфейс конкретной ячейки GKHAnyCellViewModel
protocol GKHAnyCellInputProtocol {
    var lable: String { get }
    var titleLable: String { get }
    var organizationImage: String { get }
    var textFiedText: String? { get }
}

typealias GKHAnyCellViewModelType = AdaptedCellViewModelProtocol & GKHAnyCellInputProtocol
