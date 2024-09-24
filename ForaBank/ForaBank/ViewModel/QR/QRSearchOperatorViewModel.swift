//
//  QRSearchOperatorViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.11.2022.
//

import SwiftUI
import Combine

class QRSearchOperatorViewModel: ObservableObject {
    
    let model: Model
    let navigationBar: NavigationBarView.ViewModel
    let searchBar: SearchBarView.ViewModel
    let noCompanyInListViewModel: NoCompanyInListViewModel

    @Published var operators: [QRSearchOperatorComponent.ViewModel] = []
    @Published var filteredOperators: [QRSearchOperatorComponent.ViewModel] = []
    @Published var sheet: Sheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var searchValue: SearchValue = .empty

    private var bindings = Set<AnyCancellable>()
    
    init(searchBar: SearchBarView.ViewModel, navigationBar: NavigationBarView.ViewModel, model: Model, addCompanyAction: @escaping () -> Void, requisitesAction: @escaping () -> Void) {
        
        self.searchBar = searchBar
        self.navigationBar = navigationBar
        self.model = model
        self.noCompanyInListViewModel = .init(title: NoCompanyInListViewModel.defaultTitle, content: NoCompanyInListViewModel.defaultContent, subtitle: NoCompanyInListViewModel.defaultSubtitle, addCompanyAction: addCompanyAction, requisitesAction: requisitesAction)
        
        //TODO: create convenience init 
        bind()
        let operatorsData = model.dictionaryQRAnewayOperator().filter({ !$0.parameterList.isEmpty })
        self.operators = operatorsData.map { QRSearchOperatorComponent.ViewModel(id: $0.id.description, operators: $0, action: { [weak self] id in

            guard let model = self?.model else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                
                if let operatorData = operatorsData.filter({$0.id.description == id}).first {
                    
                    if Payments.paymentsServicesOperators.map(\.rawValue).contains(operatorData.parentCode) {
                        
                        //new payment
                        Task { [weak self] in
                            
                            guard let self = self else { return }
                            let puref = operatorData.code
                            let paymentsViewModel = PaymentsViewModel(
                                source: .servicePayment(puref: puref, additionalList: nil, amount: 0, productId: nil),
                                model: model,
                                closeAction: {
                                    
                                    self.model.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                })
                            await MainActor.run {
                                
                                self.link = .payments(paymentsViewModel)
                            }
                        }
                    }
                    else {
                        
                        //old payment
                        let viewModel: InternetTVDetailsViewModel = .init(model: model, operatorData: operatorData, closeAction: { [weak self] in
                            
                            self?.link = nil
                        })
                        
                        self?.link = .operation(viewModel)
                    }
                }
            }
        })
        }
    }
    
    convenience init(searchBar: SearchBarView.ViewModel, navigationBar: NavigationBarView.ViewModel, model: Model, operators: [OperatorGroupData.OperatorData], addCompanyAction: @escaping () -> Void, requisitesAction: @escaping () -> Void, qrCode: QRCode) {
        
        self.init(searchBar: searchBar, navigationBar: navigationBar, model: model, addCompanyAction: addCompanyAction, requisitesAction: requisitesAction)
        
        guard let qrMapping = model.qrMapping.value else {
            return
        }
        
        self.operators = operators.map { operatorValue in
            if Payments.paymentsServicesOperators.map(\.rawValue).contains(operatorValue.parentCode) {
                //new payment
                return QRSearchOperatorComponent.ViewModel(id: operatorValue.id.description, operators: operatorValue, action: {[weak self]  _ in
                    guard let self = self else { return }
                    
                    Task {
                        
                        let puref = operatorValue.code
                        let additionalList = model.additionalList(for: operatorValue, qrCode: qrCode)
                        let amount: Double = qrCode.rawData["sum"]?.toDouble() ?? 0
                        let paymentsViewModel = PaymentsViewModel(
                            source: .servicePayment(puref: puref, additionalList: additionalList, amount: amount/100, productId: nil),
                            model: model,
                            closeAction: {
                                self.model.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })
                        await MainActor.run {
                            
                            self.link = .payments(paymentsViewModel)
                        }
                    }
                    
                })
            }
            else {
                //old payment
                return QRSearchOperatorComponent.ViewModel(id: operatorValue.id.description, operators: operatorValue, action: { [weak self] _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                        let viewModel: InternetTVDetailsViewModel  = .init(model: model, qrCode: qrCode, mapping: qrMapping)
                        self?.link = .operation(viewModel)
                    }
                })
            }
        }
    }
    
    func bind() {
        
        searchBar.textFieldModel.textPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                                
                self.filteredOperators.removeAll()
                                
                if text.doesNotContainNumber {
                    
                    filteredOperators = operators.filter {
                        $0.title.lowercased().prefix(text.count) == text.lowercased()
                    }
                    
                    if filteredOperators.isEmpty {
                        self.searchValue = .noResult
                        return
                    }
                    
                    switch text.doesContainLetters {
                    case true:
                        self.searchValue = .noEmpty
                    case false:
                        self.searchValue = .empty
                    }
                    
                } else {
                    
                    filteredOperators = operators.filter { $0.description?.prefix(text.count) ?? "" == text }
                    
                    if filteredOperators.isEmpty {
                        
                        self.searchValue = .noResult
                        return
                    }
                    
                    switch text.doesContainNumerics {
                    case true:
                        self.searchValue = .noEmpty
                    case false:
                        self.searchValue = .empty
                    }
                }
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case _ as QRSearchOperatorViewModelAction.OpenCityView:
                    self.sheet = .init(
                        sheetType: .city(
                            .init(
                                regions: model.dictionaryAnywayOperators()?.compactMap(\.region).uniqued() ?? [],
                                searchViewModel: .withText("Введите название города"),
                                select: { region in
                                    
                                    let regions = self.model.dictionaryRegion(for: region)
                                    self.searchValue = .noEmpty
                                    self.filteredOperators = regions.map { QRSearchOperatorComponent.ViewModel(id: $0.id.description, operators: $0, action: { [weak self] id in
                                        
                                        guard let model = self?.model else {
                                            return
                                        }
                                        
                                        let operatorsData = model.dictionaryQRAnewayOperator()
                                        
                                        if let operatorData = operatorsData.filter({$0.id.description == id}).first {
                                            
                                            let viewModel: InternetTVDetailsViewModel = .init(model: model, operatorData: operatorData, closeAction: { [weak self] in
                                                
                                                self?.link = nil
                                            })
                                            self?.link = .operation(viewModel)
                                        }
                                    })}
                                    
                                    self.sheet = nil
                                })))
                    
                default:
                    break
                }
            }.store(in: &bindings)
    }
        
    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            
            case city(QRSearchCityViewModel)
        }
    }
    
    enum Link {
        
        case operation(InternetTVDetailsViewModel)
        case payments(PaymentsViewModel)
        
    }
    
    enum SearchValue {
        case empty
        case noEmpty
        case noResult
    }
}

enum QRSearchOperatorViewModelAction {
    
    struct OpenCityView: Action {}
}

extension String {
    
    var doesContainLetters: Bool {
        
        let letters = CharacterSet.letters
        return self.rangeOfCharacter(from: letters) != nil
    }
    
    var doesContainNumerics: Bool {
        
        let letters = CharacterSet.alphanumerics
        return self.rangeOfCharacter(from: letters) != nil
    }
    
    var doesNotContainNumber: Bool {
        
        allSatisfy { !$0.isNumber }
    }
}
