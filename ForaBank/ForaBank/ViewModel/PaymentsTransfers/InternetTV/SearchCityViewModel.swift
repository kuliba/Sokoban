//
//  SearchCityViewModel.swift
//  Vortex
//
//  Created by Andryusina Nataly on 06.04.2023.
//

import SwiftUI
import Combine

class SearchCityViewModel: ObservableObject, Identifiable {
    
    let id = UUID().uuidString
    let title = "Выберите регион"
    let action: (String) -> Void
    let operators: [OperatorGroupData.OperatorData]
    
    var model: Model
    @Published var searchView: SearchBarView.ViewModel
    @Published var city: [String]
    @Published var filteredCity: [String] = []
    private var bindings = Set<AnyCancellable>()
    
    internal init(model: Model, searchView: SearchBarView.ViewModel, operators: [OperatorGroupData.OperatorData],  action: @escaping (String) -> Void) {
        
        self.model = model
        self.searchView = searchView
        self.city = []
        self.action = action
        self.operators = operators
        self.city = operators.compactMap{$0.region}.uniqued().sorted(by: {$0.lowercased() < $1.lowercased()}).sorted(by: {$0.localizedCaseInsensitiveCompare($1) == .orderedAscending})
        // "Все регионы" всегда должны быть первым элементом в списке
        if let index = self.city.firstIndex(of: PaymentsServicesViewModel.allRegion) {
            self.city.remove(at: index)
        }
        self.city.insert(PaymentsServicesViewModel.allRegion, at: 0)
        bind()
    }
    
    func bind() {
        
        searchView.textFieldModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                
                if let value = value, !value.isEmpty {
                    
                    filteredCity.removeAll()
                    filteredCity = city.filter { $0.lowercased().contains(value.lowercased()) }
                } else {
                    filteredCity = city
                }
                
            }.store(in: &bindings)
    }
}
