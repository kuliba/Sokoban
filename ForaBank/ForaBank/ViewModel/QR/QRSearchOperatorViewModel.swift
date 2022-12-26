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
    let textFieldPlaceholder: String
    let emptyViewTitle: String
    let emptyViewContent: String
    let emptyViewSubtitle: String
    
    var searchOperatorButton: [ButtonSimpleView.ViewModel]
    @Published var operators: [QRSearchOperatorComponent.ViewModel]
    @Published var filteredOperators: [QRSearchOperatorComponent.ViewModel] = []
    @Published var sheet: Sheet?
    @Published var textFieldValue: String = ""
    @Published var searchValue: SearchValue = .empty

    private var bindings = Set<AnyCancellable>()
    
    init(textFieldPlaceholder: String,navigationBar: NavigationBarView.ViewModel, model: Model) {
        self.textFieldPlaceholder = textFieldPlaceholder
        self.navigationBar = navigationBar
        self.model = model
        self.operators = []
        self.searchOperatorButton = []
        self.emptyViewTitle = "Нет компании в списке?"
        self.emptyViewContent = "Воспользуйтесь другими способами оплаты"
        self.emptyViewSubtitle = "Сообщите нам, и мы подключим новую организацию"
        self.searchOperatorButton = self.createButtons()
        bind()
        let operatorsData = model.dictionaryQRAnewayOperator()
        self.operators = operatorsData.map {QRSearchOperatorComponent.ViewModel.init(operators: $0) }
    }
    
    convenience init(textFieldPlaceholder: String, navigationBar: NavigationBarView.ViewModel, model: Model, operators: [OperatorGroupData.OperatorData]) {
        
        self.init(textFieldPlaceholder: textFieldPlaceholder, navigationBar: navigationBar, model: model)
        
        self.operators = operators.map {QRSearchOperatorComponent.ViewModel.init(operators: $0) }
    }
    
    func bind() {
        
        $textFieldValue
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                
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
                    self.sheet = .init(sheetType: .city(.init(model: model, action: { region in
                        
                        let regions = self.model.dictionaryRegion(for: region)
                        self.searchValue = .noEmpty
                        self.filteredOperators = regions.map {QRSearchOperatorComponent.ViewModel.init(operators: $0) }
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
    
    enum SearchValue {
        case empty
        case noEmpty
        case noResult
    }
    
    private func createButtons() -> [ButtonSimpleView.ViewModel] {
        
        return [
            ButtonSimpleView.ViewModel(title: "Оплатить по реквизитам", style: .gray, action: {}),
            ButtonSimpleView.ViewModel(title: "Добавить организацию", style: .gray, action: {})
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
