//
//  PaymentsSuccessTransferNumberComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 23.06.2023.
//

import SwiftUI

extension PaymentsSuccessTransferNumberView {
    
    final class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let title: String
        @Published private(set) var state: State
        
        enum State {
            
            case copy
            case check
        }
        
        init(title: String, state: State, source: PaymentsParameterRepresentable) {
            
            self.title = title
            self.state = state
            
            super.init(source: source)
        }
        
        convenience init(_ source: Payments.ParameterSuccessTransferNumber) {
            
            self.init(title: source.value ?? "", state: .copy, source: source)
        }
        
        func copyButtonDidTapped() {
            
            UIPasteboard.general.string = source.value
            
            state = .check
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {[weak self] in
                
                self?.state = .copy
            }
        }
    }
}

struct PaymentsSuccessTransferNumberView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack {
            
            Text(viewModel.title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.black)
                .padding(.leading, 6)
            
            switch viewModel.state {
            case .copy:
                Button {
                    
                    viewModel.copyButtonDidTapped()
                    
                } label: {
                    
                    Image.ic24Copy
                        .resizable()
                        .foregroundColor(.iconGray)
                        .frame(width: 24, height: 24)
                    
                }.padding(6)
                
            case .check:
                
                Image.ic24Check
                    .resizable()
                    .foregroundColor(.iconGray)
                    .frame(width: 24, height: 24)
                    .padding(6)
            }
        }
        .padding(8)
        .background(Color(hex: "F6F6F7"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.default, value: viewModel.state)
        
    }
}

