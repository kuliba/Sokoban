//
//  QRSearchCityViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.12.2022.
//

import SwiftUI
import Combine

class QRSearchCityViewModel: ObservableObject, Identifiable {
    
    let id = UUID().uuidString
    let title = "Выберите регион"
    let textFieldPlaceholder = "Введите название города"
    let action: (String) -> Void
    
    var model: Model
    @Published var city: [String]
    @Published var filteredCity: [String] = []
    @Published var textFieldValue: String = ""
    private var bindings = Set<AnyCancellable>()
    
    internal init(model: Model, action: @escaping (String) -> Void) {
        
        self.model = model
        self.city = []
        self.action = action
        
        guard let operatorsData = model.dictionaryAnywayOperators() else { return }
        self.city = operatorsData.compactMap{$0.city}
        bind()
    }
    
    func bind() {
        
        $textFieldValue
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                
                if !self.doStringContainsNumber(value) {
                    filteredCity = city.filter { $0.lowercased().prefix(value.count) == value.lowercased() }
                }
                
            }.store(in: &bindings)
    }
    
    func doStringContainsNumber(_ string : String) -> Bool{
        
        let numberRegEx  = ".*[0-9]+.*"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let containsNumber = testCase.evaluate(with: string)
        return containsNumber
        
    }
}
