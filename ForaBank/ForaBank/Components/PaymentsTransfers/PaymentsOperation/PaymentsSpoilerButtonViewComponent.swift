//
//  PaymentsSpoilerButtonViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsSpoilerButtonView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let title: String
        @Published var isSelected: Bool
        let icon = Image("Payments Icon Chevron Down")
   
        init(title: String, isSelected: Bool, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.title = title
            self.isSelected = isSelected
            super.init(source: source)
            
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

struct PaymentsSpoilerButtonView: View {
    
    @ObservedObject var viewModel: PaymentsSpoilerButtonView.ViewModel
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.mainColorsWhite)
                .frame(height: 44)
            
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
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

//MARK: - Preview

struct PaymentsButtonAdditionalView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            
            PaymentsSpoilerButtonView(viewModel: .sampleSelected)
                .previewLayout(.fixed(width: 375, height: 60))
                .previewDisplayName("Selected")
            
            PaymentsSpoilerButtonView(viewModel: .sampleNotSelected)
                .previewLayout(.fixed(width: 375, height: 60))
                .previewDisplayName("Selected")
            
            PaymentsSpoilerGroupView(viewModel: .init(items: [], isCollapsed: true))
                .previewLayout(.fixed(width: 375, height: 90))
                .previewDisplayName("Spoiler Group")
        }
    }
}

//MARK: - Preview Content

extension PaymentsSpoilerButtonView.ViewModel {
    
    static let sampleSelected = PaymentsSpoilerButtonView.ViewModel(title: "Дополнительные данные", isSelected: true)
    
    static let sampleNotSelected = PaymentsSpoilerButtonView.ViewModel(title: "Дополнительные данные", isSelected: false)
}
