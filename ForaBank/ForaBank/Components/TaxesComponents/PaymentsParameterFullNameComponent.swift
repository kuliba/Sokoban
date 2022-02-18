//
//  PaymentsParameterFullNameComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.02.2022.
//

import SwiftUI
import Combine

extension PaymentsParameterFullNameView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        var value: String // "Иванов Иван Иванович"
        let icon: Image
        @Published var personName: PersonNameViewModel
        @Published var mode: Mode = .normal
        @Published var switchButton: SwitchButtonViewModel
        private var bindings = Set<AnyCancellable>()
        
        enum Mode {
            
            case normal
            case edit
        }
        
        class SwitchButtonViewModel: ObservableObject {
            
            var icon: Image
            @Published var mode: ViewModel.Mode
            let action: () -> Void
            private var bindings = Set<AnyCancellable>()
            func bind() {
                $mode
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] mode in
                        switch mode {
                        case .normal:
                            self.icon = Image("extensionButton")
                        case .edit:
                            self.icon = Image("minus-square")
                        }
        
                    }.store(in: &bindings)
            }
            
            init(mode: ViewModel.Mode, action: @escaping () -> Void) {
                
                self.action = action
                self.mode = mode
                switch mode {
                case .normal:
                    self.icon = Image("extensionButton")
                case .edit:
                    self.icon = Image("minus-square")
                }
                bind()
            }
        }
        
        class PersonNameViewModel: ObservableObject {
            
            @Published var fullName: String
            @Published var firstName: String
            @Published var lastName: String
            @Published var surName: String
            var value: String
            private var bindings = Set<AnyCancellable>()
            
            func bind() {
                
                $firstName
                    .debounce(for: 0.8, scheduler: RunLoop.main)
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] firstName in
                        
                        fullName = fullName(firstName: firstName, lastName: lastName, surName: surName)
        
                    }
                    
                    .store(in: &bindings)
                
                $lastName
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] lastName in
                        
                        fullName = fullName(firstName: firstName, lastName: lastName, surName: surName)
        
                    }.store(in: &bindings)
                
                $surName
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] surName in
                        
                        fullName = fullName(firstName: firstName, lastName: lastName, surName: surName)
        
                    }.store(in: &bindings)
                
            }
            
            func fullName(firstName: String, lastName: String, surName: String) -> String {
        
                if (!firstName.isEmpty && !lastName.isEmpty) {
                    fullName = firstName + "" + surName + "" + lastName
                } else {
                    fullName = value
                }
                return fullName
            }
            
            init(fullName: String, firstName: String, lastName: String, surName: String, value: String) {
                
                self.fullName =  fullName
                self.firstName = firstName
                self.lastName = lastName
                self.surName = surName
                self.value = value
                bind()
            }
        }
        
        func bind() {
            $mode
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] mode in
                    switchButton.mode = mode
    
                }.store(in: &bindings)
        }
        
        internal init(value: String, icon: Image) {
            self.value = value
            self.icon = icon
            switchButton = SwitchButtonViewModel(mode: .normal,
                                                 action: {})
            personName = PersonNameViewModel(fullName:  "",
                                             firstName: "",
                                             lastName:  "",
                                             surName:   "", value: self.value)
            super.init()
            bind()
        }
    }
}

struct PaymentsParameterFullNameView: View {
    
    @ObservedObject var viewModel: PaymentsParameterFullNameView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 10) {
            
            viewModel.icon
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 30)  {
                
                switch viewModel.mode {
                    
                case .normal:
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            Text(viewModel.personName.fullName)
                                .font(Font.custom("Inter-Regular", size: 14))
                                .foregroundColor(Color(hex: "#999999"))
                                .padding(.top, 10)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    viewModel.mode = .edit
                                }
                            }, label: {
                                    viewModel.switchButton.icon
                            })
                        }
                        Divider()
                            .frame(height: 1)
                            .background(Color(hex: "#EAEBEB"))
                    }
                    
                case .edit:
                    VStack(spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            
                            TextField("Фамилия", text: $viewModel.personName.firstName,
                                      onEditingChanged: { isChanged in
                                if isChanged {
                                    /// Валидация
                                }
                            })
                                .foregroundColor(Color(hex: "#1C1C1C"))
                                .font(Font.custom("Inter-Medium", size: 14))
                                .padding(.top, 10)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    viewModel.mode = .normal
                                }
                            }, label: {
                                viewModel.switchButton.icon
                        })
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color(hex: "#EAEBEB"))
                        
                    }.textFieldStyle(DefaultTextFieldStyle())
                    
                    VStack(spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            
                            TextField("Имя", text: $viewModel.personName.lastName,
                                      onEditingChanged: { isChanged in
                                if isChanged {
                                    /// Валидация
                                }
                            })
                                .foregroundColor(Color(hex: "#1C1C1C"))
                                .font(Font.custom("Inter-Medium", size: 14))
                            
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color(hex: "#EAEBEB"))
                        
                    }.textFieldStyle(DefaultTextFieldStyle())
                    
                    VStack(spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            
                            TextField("Отчество", text: $viewModel.personName.surName,
                                      onEditingChanged: { isChanged in
                                if isChanged {
                                    /// Валидация
                                }
                            })
                                .foregroundColor(Color(hex: "#1C1C1C"))
                                .font(Font.custom("Inter-Medium", size: 14))
                            
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color(hex: "#EAEBEB"))
                        
                    }.textFieldStyle(DefaultTextFieldStyle())
                }
            }
            
            Spacer()
        }
        .transition(.opacity)
    }
}


struct PaymentsParameterFullNameView_Previews: PreviewProvider {
    static var previews: some View {
        VStack() {
            PaymentsParameterFullNameView(viewModel: .init(value: "Иванов Иван Иванович", icon: Image("accountImage"))  )
            .previewLayout(.fixed(width: 375, height: 156))
            Spacer()
        }
    }
}
