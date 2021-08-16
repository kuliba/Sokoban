//
//  GKHMainViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import Foundation

class GKHMainViewModel: AdaptedSectionViewModelType {
    
    // MARK: - Public properties
    
    var sections: [AdaptedSectionViewModelProtocol]
    
    // MARK: - Init
    
    init() {
        self.sections = []
        
        self.setupMainSection()
    }
    
    // MARK: - Private methods
    
    private func setupMainSection() {
        /// Создаем одну секцию
        let section = AdaptedSectionViewModel(cells: [
            GKHAnyCellViewModel(text: "Организация", titleLable: "", organizationImage: ""),
        ])
        /// Добавляем созданную секцию в массив секций
        sections.append(section)
    }
    
}

