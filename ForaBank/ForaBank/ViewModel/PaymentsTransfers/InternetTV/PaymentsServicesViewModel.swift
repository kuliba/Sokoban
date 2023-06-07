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

    static let allRegion = "Все регионы"
    
    let model: Model
    let navigationBar: NavigationBarView.ViewModel
    let searchBar: SearchBarView.ViewModel
    let noCompanyInListViewModel: NoCompanyInListViewModel
 
    let allOperators: [OperatorGroupData.OperatorData]
    
    @Published var latestPayments: PaymentsServicesLatestPaymentsSectionViewModel

    @Published var operators: [ItemViewModel] = []
    @Published var filteredOperators: [ItemViewModel] = []
    @Published var sheet: Sheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var searchValue: SearchValue = .empty
    
    private var bindings = Set<AnyCancellable>()
    
    init(searchBar: SearchBarView.ViewModel, navigationBar: NavigationBarView.ViewModel, model: Model, latestPayments: PaymentsServicesLatestPaymentsSectionViewModel, allOperators: [OperatorGroupData.OperatorData], addCompanyAction: @escaping () -> Void, requisitesAction: @escaping () -> Void) {
        
        self.searchBar = searchBar
        self.navigationBar = navigationBar
        self.model = model
        self.allOperators = allOperators
        self.noCompanyInListViewModel = .init(title: NoCompanyInListViewModel.defaultTitle, content: NoCompanyInListViewModel.defaultContent, subtitle: NoCompanyInListViewModel.defaultSubtitle, addCompanyAction: addCompanyAction, requisitesAction: requisitesAction)
        self.latestPayments = latestPayments
        self.setStartValues()
        bind()
    }
   
    func bind() {
   
        searchBar.textFieldModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                
                self.operatorsFilter(by: .init(value: value, region: self.navigationBar.title))
            }.store(in: &bindings)
        
        latestPayments.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsServicesSectionViewModelAction.LatestPayments.ItemDidTapped:
                    Task { [weak self] in
                        
                        guard let self = self else { return }
                        
                        let paymentsViewModel = PaymentsViewModel(
                            source: .servicePayment(puref: payload.latestPayment.puref,
                                                additionalList: payload.latestPayment.additionalList,
                                                amount: payload.latestPayment.amount),
                            model: model,
                            closeAction: { [weak self] in
                                self?.model.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                
                            })
                        await MainActor.run { [weak self] in
                            self?.link = .init(.payments(paymentsViewModel))
                        }
                    }
                default:
                    break
                }
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case _ as PaymentsServicesViewModelWithNavBarAction.OpenCityView:
                    self.sheet = .init(sheetType: .city(.init(model: model,
                                                              searchView: .withText("Введите название"),
                                                              operators: allOperators,
                                                              action: { region in
                        
                        self.navigationBar.title = region
                        self.operatorsFilter(by: .init(value: self.searchBar.text, region: self.navigationBar.title))
                        self.searchValue = .noEmpty
                        self.sheet = nil
                    })))
                    
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
}

//MARK: - Action

enum PaymentsServicesViewModelWithNavBarAction {
    
    struct OpenCityView: Action {}
}

//MARK: - Private helpers

extension PaymentsServicesViewModel {
    
    private func setStartValues() {
        
        self.operators = self.reduceOperators(operatorsList: allOperators)
    }
    
    private func reduceOperators(operatorsList: [OperatorGroupData.OperatorData]) -> [ItemViewModel] {
        
        let items: [ItemViewModel] = operatorsList.filter({ !$0.parameterList.isEmpty }).map {

            let operatorSubtitle = operatorSubtitle(for: $0.description)
            return ItemViewModel.init(code: $0.code, icon: $0.iconImageData, name: $0.name, description: operatorSubtitle, region: $0.region, action: { [weak self] code in
                guard let model = self?.model else { return }
                Task { [weak self] in
                    
                    guard let self = self else { return }
                    
                    let paymentsViewModel = PaymentsViewModel(
                        source: .servicePayment(puref: code, additionalList: .none, amount: 0),
                        model: model,
                        closeAction: { [weak self] in
                            self?.model.action.send(PaymentsTransfersViewModelAction.Close.Link())
                        })
                    await MainActor.run { [weak self] in
                        self?.link = .init(.payments(paymentsViewModel))
                    }
                }
            })
        }
        
        let sortedItems = items.sorted(by: {$0.name.lowercased() < $1.name.lowercased()}).sorted(by: {$0.name.caseInsensitiveCompare($1.name) == .orderedAscending})
        
        return sortedItems
    }
        
    private func operatorSubtitle (for description: String?) -> String {
        if let desc = description, !desc.isEmpty {
            return "ИНН \(desc)"
        }
        return ""
    }
    
    private func operatorsConditions (searchValue: SearchValueForOperator, allRegionsName: String) -> [(ItemViewModel) -> Bool] {

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
                }
                else { return true }
            }
        ]
        return conditions
    }
    
    private func operatorsFilter(by value: SearchValueForOperator) {
        
        let conditions: [(ItemViewModel) -> Bool] = operatorsConditions(searchValue: .init(value: value.value, region: value.region), allRegionsName: PaymentsServicesViewModel.allRegion)

        filteredOperators = operators.filter {
            operatorValue in
            conditions.reduce(true) { $0 && $1(operatorValue) }
        }

        if filteredOperators.count == 0, let searchValue = value.value, !searchValue.isEmpty {
            
            self.searchValue = .noResult
            return
        }
        self.searchValue = (value.value ?? "").isEmpty ? .empty : .noEmpty
    }
}

//MARK: - Types

extension PaymentsServicesViewModel {
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            
            case city(SearchCityViewModel)
        }
    }
    
    enum Link {
        
        case payments(PaymentsViewModel)
        case operation(InternetTVDetailsViewModel) // legacy!!!!!!
        
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
