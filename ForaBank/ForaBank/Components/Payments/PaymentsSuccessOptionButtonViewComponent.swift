//
//  PaymentsSuccessOptionButtonViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.03.2022.
//

import SwiftUI

//MARK: - ViewModel

class PaymentsSuccessOptionButtonViewModel: Identifiable {
    
    let id: UUID
    let icon: Image
    let title: String
    let action: () -> Void
    
    internal init(id: UUID, icon: Image, title: String, action: @escaping () -> Void) {
        self.id = id
        self.icon = icon
        self.title = title
        self.action = action
    }
}

//MARK: - View

extension PaymentsSuccessOptionButtonView {
    
    class ViewModel: PaymentsSuccessOptionButtonViewModel {
        
    }
}

struct PaymentsSuccessOptionButtonView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Button {
                viewModel.action()
            } label: {
                viewModel.icon
                    .frame(width: 56, height: 56)
            } .padding()
            
            Text(viewModel.title)
                .font(Font.custom("Inter-Medium", size: 12))
                .foregroundColor(Color(hex: "#1C1C1C"))

        }
    }
    
}

//MARK: - Preview

struct PaymentsSuccessOptionButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        PaymentsSuccessOptionButtonView(viewModel: .init(id: UUID(), icon: Image("Operation Details Info"), title: "Детали", action: {}))
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
