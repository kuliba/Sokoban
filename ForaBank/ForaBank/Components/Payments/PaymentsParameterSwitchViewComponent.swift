//
//  PaymentsParameterSwitchViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsParameterSwitchView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let options: [OptionViewModel]
        @Published var selected: OptionViewModel.ID
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(options: [OptionViewModel], selected: OptionViewModel.ID) {
            
            self.options = options
            self.selected = selected
            super.init(source: Payments.ParameterMock())
        }
        
        init(with parameterSwitch: Payments.ParameterSelectSwitch) throws {
            
            guard let selectedOptionId = parameterSwitch.parameter.value else {
                throw PaymentsParameterSwitchView.ViewModel.Error.noAnyOptionSelected
            }
            
            guard parameterSwitch.options.map({ $0.id }).contains(selectedOptionId) else {
                throw PaymentsParameterSwitchView.ViewModel.Error.selectedNonExistentOption
            }
            
            self.options = parameterSwitch.options.map{ OptionViewModel(id: $0.id, title: $0.name) }
            self.selected = selectedOptionId
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

struct PaymentsParameterSwitchView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack {
            
            Picker("", selection: $viewModel.selected, content: {
                
                ForEach(viewModel.options, content: { options in
                    
                    Text(options.title)
                })
                
            }).pickerStyle(.segmented)
        }
    }
}

//MARK: - Preview

struct PaymentsParameterSwitchView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsParameterSwitchView(viewModel: .sampleParameter)
                .previewLayout(.fixed(width: 375, height: 56))
                .previewDisplayName("Parameter")
            
            PaymentsParameterSwitchView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 56))
        }
    }
}

//MARK: - Preview Content

extension PaymentsParameterSwitchView.ViewModel {
    
    static let sample: PaymentsParameterSwitchView.ViewModel = {
        
        let firstOption = PaymentsParameterSwitchView.ViewModel.OptionViewModel(title: "Документ")
        
        return PaymentsParameterSwitchView.ViewModel(options: [firstOption, .init(title: "УИН"), .init(title: "ИП")], selected: firstOption.id)
    }()
    
    static let sampleParameter: PaymentsParameterSwitchView.ViewModel = {
        
        let parameter = Payments.ParameterSelectSwitch( .init(id: UUID().uuidString, value: "2"), options: [.init(id: "1", name: "Документ"), .init(id: "2", name: "УИН"), .init(id: "3", name: "ИП")])
        return try! PaymentsParameterSwitchView.ViewModel(with: parameter)
    }()
}

