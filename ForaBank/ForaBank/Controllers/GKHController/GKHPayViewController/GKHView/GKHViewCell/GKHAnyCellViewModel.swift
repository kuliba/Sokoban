//
//  GKHAnyCellViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import Foundation

/// ViewModel ячейки
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
