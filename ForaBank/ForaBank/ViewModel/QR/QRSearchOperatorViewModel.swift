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
    let emptyViewTitle: String
    let emptyViewContent: String
    let emptyViewSubtitle: String
    
    var searchOperatorButton: [ButtonSimpleView.ViewModel]
    @Published var operators: [QRSearchOperatorComponent.ViewModel]
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
        self.operators = []
        self.searchOperatorButton = []
        self.emptyViewTitle = "Нет компании в списке?"
        self.emptyViewContent = "Воспользуйтесь другими способами оплаты"
        self.emptyViewSubtitle = "Сообщите нам, и мы подключим новую организацию"
        self.searchOperatorButton = self.createButtons(addCompanyAction: addCompanyAction, requisitesAction: requisitesAction)
        
        //TODO: create convenience init 
        bind()
        let operatorsData = model.dictionaryQRAnewayOperator().filter({$0.parameterList.count > 1})
        self.operators = operatorsData.map { QRSearchOperatorComponent.ViewModel(id: $0.id.description, operators: $0, action: { [weak self] id in

            guard let model = self?.model else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                
                if let operatorData = operatorsData.filter({$0.id.description == id}).first {

                    let viewModel: InternetTVDetailsViewModel = .init(model: model, operatorData: operatorData, closeAction: { [weak self] in

                        self?.link = nil
                    })

                    self?.link = .operation(viewModel)
                }
            }
        })
        }
    }
    
    convenience init(searchBar: SearchBarView.ViewModel, navigationBar: NavigationBarView.ViewModel, model: Model, operators: [OperatorGroupData.OperatorData], addCompanyAction: @escaping () -> Void, requisitesAction: @escaping () -> Void, qrCode: QRCode) {
        
        self.init(searchBar: searchBar, navigationBar: navigationBar, model: model, addCompanyAction: addCompanyAction, requisitesAction: requisitesAction)
        
        self.operators = operators.map {QRSearchOperatorComponent.ViewModel(id: $0.id.description, operators: $0, action: { [weak self] _ in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                
                if let qrMapping = model.qrMapping.value {
                 
                    let viewModel: InternetTVDetailsViewModel  = .init(model: model, qrCode: qrCode, mapping: qrMapping)
                    self?.link = .operation(viewModel)

                }
            }
        }) }
    }
    
    func bind() {
        
        searchBar.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                
                guard let value = value else {
                    return
                }
                
                self.filteredOperators.removeAll()
                                
                if !self.doStringContainsNumber(_string: value) {
                    
                    filteredOperators = operators.filter { $0.title.lowercased().prefix(value.count) == value.lowercased() }
                    
                    if filteredOperators.count == 0 {
                        self.searchValue = .noResult
                        return
                    }
                    
                    switch value.isContainsLetters {
                    case true:
                        self.searchValue = .noEmpty
                    case false:
                        self.searchValue = .empty
                    }
                    
                } else {
                    
                    filteredOperators = operators.filter { $0.description?.prefix(value.count) ?? "" == value }
                    
                    if filteredOperators.count == 0 {
                        self.searchValue = .noResult
                        return
                    }
                    
                    switch value.isContainsNumerics {
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
                    self.sheet = .init(sheetType: .city(.init(model: model, searchView: .init(textFieldPhoneNumberView: .init(.text("Введите название города"))), action: { region in
                        
                        let regions = self.model.dictionaryRegion(for: region)
                        self.searchValue = .noEmpty
                        self.filteredOperators = regions.map {QRSearchOperatorComponent.ViewModel(id: $0.id.description, operators: $0, action: { [weak self] id in
                            
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
    
    func doStringContainsNumber( _string : String) -> Bool{
        
        let numberRegEx  = ".*[0-9]+.*"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let containsNumber = testCase.evaluate(with: _string)
        return containsNumber
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
    }
    
    enum SearchValue {
        case empty
        case noEmpty
        case noResult
    }
    
    private func createButtons(addCompanyAction: @escaping () -> Void, requisitesAction: @escaping () -> Void) -> [ButtonSimpleView.ViewModel] {
        
        return [
            ButtonSimpleView.ViewModel(title: "Оплатить по реквизитам", style: .gray, action: requisitesAction),
            ButtonSimpleView.ViewModel(title: "Добавить организацию", style: .gray, action: addCompanyAction)
        ]
    }
}

enum QRSearchOperatorViewModelAction {
    
    struct OpenCityView: Action {}
}

extension String{
    
    var isContainsLetters : Bool{
        let letters = CharacterSet.letters
        return self.rangeOfCharacter(from: letters) != nil
    }
    
    var isContainsNumerics : Bool{
        let letters = CharacterSet.alphanumerics
        return self.rangeOfCharacter(from: letters) != nil
    }
}
