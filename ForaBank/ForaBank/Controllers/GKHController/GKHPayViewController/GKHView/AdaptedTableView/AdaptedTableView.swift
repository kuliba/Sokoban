//
//  AdaptedTableView.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import UIKit
import Combine

/// ViewModel
class AdaptedTableView: UITableView {
    
    // MARK: - Public properties
    
    var viewModel: AdaptedSectionViewModelType?
    var cellFactory: AdaptedSectionFactoryProtocol? {
        didSet {
            cellFactory?.registerAllCells(self)
        }
    }
    
    // MARK: - Private properties
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Public methods
    /// Метод конфигурации таблицы
    func setup() {
        self.dataSource = self
        self.delegate = self
        self.backgroundView = UIView() //Create a backgroundView
        self.backgroundView!.backgroundColor = .white //choose your background color
        self.separatorStyle = .none
        self.bindSections()
    }
    
    // MARK: - Private methods
    
    private func bindSections() {
        viewModel?.sections.enumerated().forEach({ (index, section) in
            section.reloadDataPublisher.sink { [weak self] in
                self?.reloadSections([index], with: .automatic)
            }.store(in: &cancellables)
        })
    }
    
}

