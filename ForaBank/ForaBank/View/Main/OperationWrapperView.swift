//
//  OperationWrapperView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 15.11.2023.
//

import Foundation
import PaymentSticker
import SwiftUI
import Combine

final class OperationWrapperViewModel: ObservableObject {
    
    @ObservedObject var model: OperationStateViewModel
    @ObservedObject var placesViewModel: PlacesListViewModel
    @Published var isLinkActive: Bool = true
    
    private var bindings = Set<AnyCancellable>()
    
    internal init(
        model: OperationStateViewModel,
        placesViewModel: PlacesListViewModel
    ) {
        self.model = model
        self.placesViewModel = placesViewModel
        
        bind()
    }
    
    private func bind() {
        
        placesViewModel.action
            .receive(on: DispatchQueue.main)
            .compactMap { $0 as? PlacesListViewModelAction.ItemDidSelected }
            .sink { payload in
                
                self.isLinkActive = false
                self.model.event(.select(.selectOption("", .init(
                    id: .officeSelector,
                    value: payload.name,
                    title: "Выберите отделение",
                    placeholder: "Выберите отделение",
                    options: [],
                    state: .selected(.init(
                        title: "Выберите отделение",
                        placeholder: "",
                        name: payload.name,
                        iconName: "ic24Bank"
                    ))))))
                
            }.store(in: &bindings)
    }
}

struct OperationWrapperView: View {
    
    @ObservedObject var operationWrapperViewModel: OperationWrapperViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                VStack {
                    
                    OperationView(
                        model: operationWrapperViewModel.model,
                        configuration: MainView.configurationOperationView()
                    )
                    .navigationBarTitle("Оформление заявки", displayMode: .inline)
                    .edgesIgnoringSafeArea(.bottom)
                }
                
                NavigationLink("", isActive: $operationWrapperViewModel.isLinkActive) {
                    
                    PlacesListView(viewModel: operationWrapperViewModel.placesViewModel)
                }
            }
        }
    }
}
