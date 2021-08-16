//
//  AdaptedSectionViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import Foundation
import Combine

protocol AdaptedSectionHeaderViewModelProtocol { }

/// AdaptedSectionViewModelProtocol необходим для описания viewModel секции
protocol AdaptedSectionViewModelProtocol {
    var header: AdaptedSectionHeaderViewModelProtocol? { get }
    var footer: AdaptedSectionHeaderViewModelProtocol? { get }
    var cells: [AdaptedCellViewModelProtocol] { get }
    var reloadDataPublisher: AnyPublisher<Void, Never> { get }
}

protocol AdaptedViewModelInputProtocol {
    var sections: [AdaptedSectionViewModelProtocol] { get }
}

protocol AdaptedViewModelOutputProtocol {
    func didSelectRowAt(indexPath: IndexPath)
}

extension AdaptedViewModelOutputProtocol {
    func didSelectRowAt(indexPath: IndexPath) { }
}

typealias AdaptedSectionViewModelType = AdaptedViewModelInputProtocol & AdaptedViewModelOutputProtocol

class AdaptedSectionViewModel: AdaptedSectionViewModelProtocol {
    
    // MARK: - Public properties
    
    var header: AdaptedSectionHeaderViewModelProtocol?
    var footer: AdaptedSectionHeaderViewModelProtocol?
    var cells: [AdaptedCellViewModelProtocol] {
        didSet {
            reloadDataSubject.send()
        }
    }
    
    var reloadDataPublisher: AnyPublisher<Void, Never> {
        reloadDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private properties
    
    private let reloadDataSubject: PassthroughSubject<Void, Never>
    
    // MARK: - Init
    
    init(header: AdaptedSectionHeaderViewModelProtocol? = nil,
         footer: AdaptedSectionHeaderViewModelProtocol? = nil,
         cells: [AdaptedCellViewModelProtocol]) {
        self.header = header
        self.footer = footer
        self.cells = cells
        self.reloadDataSubject = PassthroughSubject<Void, Never>()
    }
    
}
