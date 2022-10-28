//
//  PaymentsButtonAdditionalViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsButtonAdditionalView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let title: String
        @Published var isSelected: Bool
        let icon = Image("Payments Icon Chevron Down")
        
        private var bindings = Set<AnyCancellable>()
   
        init(title: String, isSelected: Bool) {
            
            self.title = title
            self.isSelected = isSelected
            super.init(source: Payments.ParameterMock())
            
            bind()
        }
        
        private func bind() {
            
            $isSelected
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] isSelected in
                    
                    action.send(PaymentsParameterViewModelAction.SpoilerButton.DidUpdated(isCollapsed: isSelected))
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {

    enum SpoilerButton {
    
        struct DidUpdated: Action {
            
            let isCollapsed: Bool
        }
    }
}

//MARK: - View

struct PaymentsButtonAdditionalView: View {
    
    @ObservedObject var viewModel: PaymentsButtonAdditionalView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .center) {
            
            Button {
                
                viewModel.isSelected.toggle()
                
            } label: {
                
                HStack(spacing: 10) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .rotationEffect(viewModel.isSelected ? .degrees(0) : .degrees(180))

                    Text(viewModel.title)
                        .font(Font.custom("Inter-Medium", size: 14))
                        .foregroundColor(Color(hex: "#1C1C1C"))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "#F6F6F7"))
        .cornerRadius(8)
    }
}

//MARK: - Preview

struct PaymentsButtonAdditionalView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsButtonAdditionalView(viewModel: .init(title: "Дополнительные данные", isSelected: false))
                .previewLayout(.fixed(width: 375, height: 60))
            
            PaymentsButtonAdditionalView(viewModel: .init(title: "Дополнительные данные", isSelected: true))
                .previewLayout(.fixed(width: 375, height: 60))
        }
    }
}
