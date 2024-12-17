//
//  RootViewModelFactory+makeOperatorSearchNode.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.11.2024.
//

extension RootViewModelFactory {
    
    enum QRSearchOperatorEvent: Equatable {
        
        case addCompany
        case detailPayment
        case dismiss
    }
    
    func makeOperatorSearch(
        multiple: MultipleQRResult,
        notify: @escaping (QRSearchOperatorEvent) -> Void
    ) -> QRSearchOperatorViewModel {
        
        let navigationBarViewModel = NavigationBarView.ViewModel(
            title: "Все регионы",
            titleButton: .init(
                icon: .ic24ChevronDown,
                action: { [weak self] in
                    
                    self?.model.action.send(QRSearchOperatorViewModelAction.OpenCityView())
                }
            ),
            leftItems: [
                NavigationBarView.ViewModel.BackButtonItemViewModel(
                    icon: .ic24ChevronLeft,
                    action: { notify(.dismiss) }
                )
            ]
        )
        
        return .init(
            searchBar: .nameOrTaxCode(),
            navigationBar: navigationBarViewModel, model: self.model,
            operators: multiple.operators.elements.map(\.origin),
            addCompanyAction: { notify(.addCompany) },
            requisitesAction: { notify(.detailPayment) },
            qrCode: multiple.qrCode
        )
    }
}
