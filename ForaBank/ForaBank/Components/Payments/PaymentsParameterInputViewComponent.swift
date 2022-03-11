//
//  PaymentsParameterInputViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsParameterInputView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let logo: Image
        let description: String
        @Published var content: String
        @Published var title: String?
        let validator: Payments.ParameterInput.Validator
        private var bindings = Set<AnyCancellable>()
        
        private static let iconPlaceholder = Image("Payments Icon Placeholder")
        
        override var isValid: Bool {
            guard let inputParemetr = source as? Payments.ParameterInput else { return false }
            
            return inputParemetr.validator.isValid(value: content)
        }
        
        internal init(logo: Image, description: String, content: String? = nil) {
            
            self.logo = logo
            self.description = description
            self.content = content ?? ""
            self.validator = .init(minLength: 0, maxLength: 50, regEx: nil)
            
            super.init(source: Payments.ParameterMock())
            
            bind()
        }
        
        init(with parameterInput: Payments.ParameterInput) throws {
            
            self.logo = parameterInput.icon.image ?? Self.iconPlaceholder
            self.content = parameterInput.parameter.value ?? ""
            self.description = parameterInput.title
            self.validator = parameterInput.validator
            
            super.init(source: parameterInput)
            
            bind()
        }
        
        
        
        private func bind() {
            
            $content
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] content in
                    
                    value = value.updated(with: content)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        title = content.count > 0 ? description : nil
                    }

                }.store(in: &bindings)
        }
    }
}

//MARK: - View

struct PaymentsParameterInputView: View {
    
    @ObservedObject var viewModel: PaymentsParameterInputView.ViewModel
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            viewModel.logo
                .resizable()
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 0)  {
                
                if let title = viewModel.title {
                    
                    Text(title)
                        .font(Font.custom("Inter-Regular", size: 12))
                        .foregroundColor(Color(hex: "#999999"))
                        .padding(.bottom, 4)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                    
                } else {
                    
                    Text("")
                        .font(Font.custom("Inter-Regular", size: 12))
                        .foregroundColor(Color(hex: "#999999"))
                        .padding(.bottom, 4)
                        
                }
                
                TextField(viewModel.description, text: $viewModel.content)
                    .foregroundColor(Color(hex: "#1C1C1C"))
                    .font(Font.custom("Inter-Medium", size: 14))
                
                Divider()
                    .frame(height: 1)
                    .background(Color(hex: "#EAEBEB"))
                    .padding(.top, 12)
                
            } .textFieldStyle(DefaultTextFieldStyle())
        }
    }
}

//MARK: - Preview

struct PaymentsParameterInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsParameterInputView(viewModel: .sampleEmpty)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsParameterInputView(viewModel: .sampleValue)
                .previewLayout(.fixed(width: 375, height: 80))
        }
    }
}

//Payments Input Sample
extension PaymentsParameterInputView.ViewModel {
    
    static let sampleEmpty = PaymentsParameterInputView.ViewModel(logo: Image("Payments Input Sample"), description: "ИНН подразделения")
    
    static let sampleValue = PaymentsParameterInputView.ViewModel(logo: Image("Payments Input Sample"),description: "ИНН подразделения", content: "0016196314")
}

