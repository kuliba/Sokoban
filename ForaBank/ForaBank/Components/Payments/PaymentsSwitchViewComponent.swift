//
//  PaymentsSwitchViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsSwitchView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let options: [OptionViewModel]
        @Published var selected: OptionViewModel.ID
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(options: [OptionViewModel], selected: OptionViewModel.ID) {
            
            self.options = options
            self.selected = selected
            super.init(source: Payments.ParameterMock())
        }
        
        init(with parameterSwitch: Payments.ParameterSelectSwitch) {
        
            self.options = parameterSwitch.options.map{ OptionViewModel(id: $0.id, title: $0.name) }
            self.selected = parameterSwitch.parameter.value ?? ""
            super.init(source: parameterSwitch)
            
            bind()
        }
        
        private func bind() {
            
            $selected
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] selected in
                    
                    update(value: selected)
                }
                .store(in: &bindings)
        }
        
        struct OptionViewModel: Identifiable {
            
            var id: Payments.ParameterSelectSwitch.Option.ID = UUID().uuidString
            let title: String
        }
        
        enum Error: Swift.Error {
            
            case noAnyOptionSelected
            case selectedNonExistentOption
        }
    }
}

//MARK: - View

struct PaymentsSwitchView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        Picker("", selection: $viewModel.selected) {
            
            ForEach(viewModel.options) { option in
               
                Text(option.title)
            }
        }
        .pickerStyle(.segmented)
        .disabled(viewModel.isEditable == false)
    }
}

//MARK: - Preview

struct PaymentsSwitchView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSwitchView(viewModel: .sampleParameter)
                .previewLayout(.fixed(width: 375, height: 56))
                .previewDisplayName("Parameter")
            
            PaymentsSwitchView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 56))
        }
    }
}

//MARK: - Preview Content

extension PaymentsSwitchView.ViewModel {
    
    static let sample: PaymentsSwitchView.ViewModel = {
        
        let firstOption = PaymentsSwitchView.ViewModel.OptionViewModel(title: "Документ")
        
        return PaymentsSwitchView.ViewModel(options: [firstOption, .init(title: "УИН"), .init(title: "ИП")], selected: firstOption.id)
    }()
    
    static let sampleParameter: PaymentsSwitchView.ViewModel = {
        
        let parameter = Payments.ParameterSelectSwitch( .init(id: UUID().uuidString, value: "2"), options: [.init(id: "1", name: "Документ"), .init(id: "2", name: "УИН"), .init(id: "3", name: "ИП")])
        return try! PaymentsSwitchView.ViewModel(with: parameter)
    }()
}

