//
//  InfoViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 16.11.2022.
//

import SwiftUI

extension InfoView {

    struct ViewModel {
        
        let icon: Image
        let title: String
    }
}

struct InfoView: View {
    
    let viewModel: InfoView.ViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
    
            ZStack {
             
                Circle()
                    .fill(Color.mainColorsGrayLightest)
                    .frame(width: 88, height: 88, alignment: .center)
                
                viewModel.icon
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
            }
            
            Text(viewModel.title)
                .font(.textH4M16240())
                .multilineTextAlignment(.center)
            
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
    }
}

struct InfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InfoView(viewModel: .sample)
    }
}

extension InfoView.ViewModel {
    
    static let sample: InfoView.ViewModel = .init(icon: .ic48AlertCircle, title: "Сумма расчитана автоматически с учетом условий по вашему вкладу")
}
