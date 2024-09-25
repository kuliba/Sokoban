//
//  PaymentsServicesViewModel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 06.04.2023.
//

import SwiftUI
import Combine

class PaymentsServicesViewModel: ObservableObject {
    
    typealias ItemViewModel = PaymentsServicesOperatorItemView.ViewModel
    typealias OpenCityViewPublisher = AnyPublisher<PaymentsServicesViewModelWithNavBarAction.OpenCityView, Never>
    typealias MakePaymentsViewModel = (Payments.Operation.Source) -> PaymentsViewModel
    typealias MakeSearchCityViewModel = (String, [OperatorGroupData.OperatorData], @escaping (String) -> Void) -> SearchCityViewModel
    
    static let allRegion = "Все регионы"
    
    let searchBar: SearchBarView.ViewModel
    let navigationBar: NavigationBarView.ViewModel
    let noCompanyInListViewModel: NoCompanyInListViewModel
    
    let allOperators: [OperatorGroupData.OperatorData]
    
    @Published var latestPayments: PaymentsServicesLatestPaymentsSectionViewModel
    
    @Published var operators: [ItemViewModel] = []
    @Published var filteredOperators: [ItemViewModel] = []
    @Published var sheet: Sheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var searchValue: SearchValue = .empty
    
    private let openCityViewPublisher: OpenCityViewPublisher
    private let makePaymentsViewModel: MakePaymentsViewModel
    private let makeSearchCityViewModel: MakeSearchCityViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    init(
        searchBar: SearchBarView.ViewModel,
        navigationBar: NavigationBarView.ViewModel,
        latestPayments: PaymentsServicesLatestPaymentsSectionViewModel,
        allOperators: [OperatorGroupData.OperatorData],
        openCityViewPublisher: PaymentsServicesViewModel.OpenCityViewPublisher,
        makePaymentsViewModel: @escaping PaymentsServicesViewModel.MakePaymentsViewModel,
        makeSearchCityViewModel: @escaping PaymentsServicesViewModel.MakeSearchCityViewModel,
        addCompanyAction: @escaping () -> Void,
        requisitesAction: @escaping () -> Void
    ) {
        self.navigationBar = navigationBar
        self.searchBar = searchBar
        self.noCompanyInListViewModel = .init(
            title: NoCompanyInListViewModel.defaultTitle,
            content: NoCompanyInListViewModel.defaultContent,
            subtitle: NoCompanyInListViewModel.defaultSubtitle,
            addCompanyAction: addCompanyAction,
            requisitesAction: requisitesAction
        )
        self.allOperators = allOperators
        self.latestPayments = latestPayments
        self.openCityViewPublisher = openCityViewPublisher
        self.makePaymentsViewModel = makePaymentsViewModel
        self.makeSearchCityViewModel = makeSearchCityViewModel
        
        self.setStartValues()
        self.bind()
    }

    func bind() {
        
        searchBar.textFieldModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                
                self.operatorsFilter(by: .init(value: value, region: self.navigationBar.title))
            }
            .store(in: &bindings)
        
        latestPayments.action
            .compactMap { $0 as? PaymentsServicesSectionViewModelAction.LatestPayments.ItemDidTapped }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] payload in
                
                let paymentsViewModel = makePaymentsViewModel(
                    .servicePayment(
                        puref: payload.latestPayment.puref,
                        additionalList: payload.latestPayment.additionalList,
                        amount: payload.latestPayment.amount, 
                        productId: nil
                    )
                )
                
                Task { @MainActor [weak self] in
                    
                    self?.link = .payments(paymentsViewModel)
                }
            }
            .store(in: &bindings)
        
        openCityViewPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                self.sheet = .init(
                    sheetType: .city(
                        makeSearchCityViewModel("Введите название", allOperators) { region in
                            
                            self.navigationBar.title = region
                            self.operatorsFilter(by: .init(value: self.searchBar.text, region: self.navigationBar.title))
                            self.searchValue = .noEmpty
                            self.sheet = nil
                        }
                    )
                )
            }
            .store(in: &bindings)
    }
}

// MARK: Convenience: to use with Model

extension PaymentsServicesViewModel {
    
    convenience init(
        searchBar: SearchBarView.ViewModel,
        navigationBar: NavigationBarView.ViewModel,
        model: Model,
        latestPayments: PaymentsServicesLatestPaymentsSectionViewModel,
        allOperators: [OperatorGroupData.OperatorData],
        addCompanyAction: @escaping () -> Void,
        requisitesAction: @escaping () -> Void
    ) {
        let openCityViewPublisher = model.action
            .compactMap { $0 as? PaymentsServicesViewModelWithNavBarAction.OpenCityView }
            .eraseToAnyPublisher()
        
        self.init(
            searchBar: searchBar,
            navigationBar: navigationBar,
            latestPayments: latestPayments,
            allOperators: allOperators,
            openCityViewPublisher: openCityViewPublisher,
            makePaymentsViewModel: model.makePaymentsViewModel(source:),
            makeSearchCityViewModel: model.makeSearchCityViewModel(placeholderText:operators:action:),
            addCompanyAction: addCompanyAction,
            requisitesAction: requisitesAction
        )
    }
}

// MARK: - Action

enum PaymentsServicesViewModelWithNavBarAction {
    
    struct OpenCityView: Action {}
}

// MARK: - Private helpers

extension Model {
    
    func makePaymentsViewModel(
        source: Payments.Operation.Source
    ) -> PaymentsViewModel {
        
        return .init(
            source: source,
            model: self,
            closeAction: { [weak self] in
                
                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
            }
        )
    }
    
    func makeSearchCityViewModel(
        placeholderText: String,
        operators: [OperatorGroupData.OperatorData],
        action: @escaping (String) -> Void
    ) -> SearchCityViewModel {
        
        .init(
            model: self,
            searchView: .withText(placeholderText),
            operators: operators,
            action: action
        )
    }
}

extension PaymentsServicesViewModel {
    
    private func setStartValues() {
        
        let action: (String) -> Void = { [weak self] code in
            
            guard let link = self?.link(for: code) else { return }
            
            Task { @MainActor [weak self] in self?.link = link }
        }
        
        self.operators = Self.reduceOperators(operatorsList: allOperators, action: action)
    }
    
    func link(for code: String) -> Link {
        
        let paymentsViewModel = makePaymentsViewModel(
            .servicePayment(puref: code, additionalList: .none, amount: 0, productId: nil)
        )
        
        return .payments(paymentsViewModel)
    }
    
    static func reduceOperators(
        operatorsList: [OperatorGroupData.OperatorData],
        action: @escaping (String) -> Void
    ) -> [ItemViewModel] {
        
        return operatorsList
            .filter { !$0.parameterList.isEmpty }
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            .sorted(by: { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending })
            .map { .makeItemViewModel(from: $0, with: action) }
    }
        
    private func operatorSubtitle(for description: String?) -> String {
        
        guard let desc = description, !desc.isEmpty
        else { return "" }
        
        return "ИНН \(desc)"
    }
    
    private func operatorsConditions(searchValue: SearchValueForOperator, allRegionsName: String) -> [(ItemViewModel) -> Bool] {
        
        let conditions: [(ItemViewModel) -> Bool] = [
            {
                if searchValue.region != allRegionsName {
                    return ($0.region == searchValue.region || $0.region == nil)
                }
                else { return true }
            },
            {
                if let identifier = searchValue.value, !identifier.isEmpty {
                    
                    let searchType: SearchType = identifier.isOnlyDigits ? .inn : .name
                    
                    switch searchType {
                        
                    case .name:
                        return $0.name.lowercased().contains(identifier.lowercased())
                    case .inn:
                        return ($0.description?.lowercased() ?? "").contains(identifier.lowercased())
                    }
                } else {
                    return true
                }
            }
        ]
        
        return conditions
    }
    
    private func operatorsFilter(by value: SearchValueForOperator) {
        
        let conditions: [(ItemViewModel) -> Bool] = operatorsConditions(
            searchValue: .init(value: value.value, region: value.region),
            allRegionsName: PaymentsServicesViewModel.allRegion
        )
        
        filteredOperators = operators.filter { operatorValue in
            conditions.reduce(true) { $0 && $1(operatorValue) }
        }
        
        if filteredOperators.isEmpty,
           let searchValue = value.value,
           !searchValue.isEmpty {
            
            self.searchValue = .noResult
            return
        }
        
        self.searchValue = (value.value ?? "").isEmpty ? .empty : .noEmpty
    }
}

// MARK: - Mapper

extension PaymentsServicesViewModel.ItemViewModel {
    
    static func makeItemViewModel(
        from operatorData: OperatorGroupData.OperatorData,
        with action: @escaping (String) -> Void
    ) -> PaymentsServicesViewModel.ItemViewModel {
        
        return .init(
            code: operatorData.code,
            icon: operatorData.iconImageData,
            name: operatorData.name,
            description: operatorSubtitle(for: operatorData.description),
            region: operatorData.region,
            action: action
        )
    }
    
    private static func operatorSubtitle(for description: String?) -> String {
        
        guard let desc = description, !desc.isEmpty
        else { return "" }
        
        return "ИНН \(desc)"
    }
}

// MARK: - Types

extension PaymentsServicesViewModel {
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            
            case city(SearchCityViewModel)
        }
    }
    
    enum Link {
        
        case operation(InternetTVDetailsViewModel) // legacy!!!!!!
        case payments(PaymentsViewModel)
    }
    
    enum SearchValue {
        
        case empty
        case noEmpty
        case noResult
    }
    
    enum SearchType {
        
        case name
        case inn
    }
    
    struct SearchValueForOperator: Equatable, Hashable {
        
        let value: String?
        let region: String?
    }
}
