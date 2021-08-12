//
//  GKHAnyCellViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
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

class GKHAnyCellViewModel: GKHAnyCellViewModelType {
    
    var lable: String
    var titleLable: String
    var organizationImage: String
    var textFiedText: String?
    
    init(text: String, titleLable: String, organizationImage: String) {
        self.lable = text
        self.titleLable = titleLable
        self.organizationImage = organizationImage
    }
    
}
