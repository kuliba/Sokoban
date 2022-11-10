//
//  PaymentsSuccessOptionButtonViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.03.2022.
//

import SwiftUI

//MARK: - ViewModel

extension PaymentsSuccessOptionButtonView {
    
    class ViewModel: PaymentsSuccessOptionButtonViewModel {}
}

//MARK: - View
struct PaymentsSuccessOptionButtonView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            Button(action: viewModel.action){
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(Color.secondary)
                        .frame(width: 56, height: 56)
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            
            Text(viewModel.title)
                .font(.textBodySM12160())
                .foregroundColor(.textSecondary)
                .frame(height: 24)
        }
    }
}

//MARK: - Preview

struct PaymentsSuccessOptionButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        PaymentsSuccessOptionButtonView(viewModel: .init(id: UUID(), icon: Image("Payments Icon Success File"), title: "Детали", action: {}))
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
