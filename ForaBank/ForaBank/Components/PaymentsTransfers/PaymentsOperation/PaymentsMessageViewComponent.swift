//
//  PaymentsMessageViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 19.01.2023.
//

import SwiftUI
import Combine

//MARK: - View Model

extension PaymentsMessageView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let message: String
        @Published var isViewed: Bool
        
        init(message: String, isViewed: Bool, source: PaymentsParameterRepresentable = Payments.ParameterMock()) {
            
            self.message = message
            self.isViewed = isViewed
            super.init(source: source)
        }
        
        convenience init(with parameterMessage: Payments.ParameterMessage) {
            
            self.init(message: parameterMessage.message, isViewed: parameterMessage.isViewed, source: parameterMessage)
            
            bind()
        }
        
        private func bind() {
            
            $isViewed
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] value in
                    
                    update(value: value == true ? "true" : "false")
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - View

struct PaymentsMessageView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        if viewModel.isViewed == false {
            
            HStack {
                
                Text(viewModel.message)
                    .font(.textBodySR12160())
                    .foregroundColor(.textWhite)
                    .padding(.leading, 20)
                    .padding(.vertical, 12)
                
                Spacer()
                
                Button {
                    
                    withAnimation {
                        
                        viewModel.isViewed = true
                    }
                    
                } label: {
                    
                    Image.ic24Close
                        .renderingMode(.template)
                        .foregroundColor(.iconWhite)
                }
                .frame(width: 44, height: 44)
            }
            .frame(minHeight: 56)
            .background(Color.buttonBlack)
            
        } else {
            
            Color.clear
                .frame(height: 1)
        }
    }
}

//MARK: - Preview

struct PaymentsMessageView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsMessageView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 70))
            
            PaymentsMessageView(viewModel: .sampleShort)
                .previewLayout(.fixed(width: 375, height: 70))
            
            PaymentsMessageView(viewModel: .sampleLong)
                .previewLayout(.fixed(width: 375, height: 120))
            
            PaymentsMessageView(viewModel: .sampleClosed)
                .previewLayout(.fixed(width: 375, height: 70))
        }
    }
}

//MARK: - Preview Content

extension PaymentsMessageView.ViewModel {
    
    static let sample = PaymentsMessageView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "false"), message: "Проверьте реквизиты получателя перед совершением перевода"))
    
    static let sampleShort = PaymentsMessageView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "false"), message: "Проверьте"))
    
    static let sampleLong = PaymentsMessageView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "false"), message: "Проверьте реквизиты получателя перед совершением перевода, Проверьте реквизиты получателя перед совершением перевода, Проверьте реквизиты получателя перед совершением перевода."))
    
    static let sampleClosed = PaymentsMessageView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "true"), message: "Проверьте реквизиты получателя перед совершением перевода"))
}
