//
//  OperationDetailHeaderComponentView.swift
//  ForaBank
//
//  Created by Max Gribov on 27.12.2021.
//

import SwiftUI

extension OperationDetailHeaderComponentView {
   
    struct ViewModel {
        
        let logo: Image
        let status: OperationDetailViewModel.StatusViewModel?
        let title: String
        let category: String?
    }
}

struct OperationDetailHeaderComponentView: View {
    
    @Binding var viewModel: OperationDetailViewModel.HeaderViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            viewModel.logo
                .resizable()
                .frame(width: 64, height: 64)
            
            if let status = viewModel.status {
                
                Text(status.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: status.colorHex))
                    .padding(.top, 24)
            }
            
            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.top, 8)
                .padding(.horizontal, 24)
            
            if let category = viewModel.category {
                
                Text(category)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
    }
}


struct OperationDetailHeaderComponentView_Previews: PreviewProvider {
    static var previews: some View {
        OperationDetailHeaderComponentView(viewModel: .constant(.init(logo: Image("Operation Group Sample"), status: .reject, title: "Описание операции", category: "Категория")))
            .previewLayout(.fixed(width: 375, height: 200))
    }
}
