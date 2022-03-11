//
//  DetailAccountComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 11.03.2022.
//

import SwiftUI

extension DetailAccountComponent {
    
    class ViewModel: ObservableObject {
        
        @Published var headerView: HeaderViewModel
        
        struct HeaderViewModel {
            let title = "Детали счета"
            let subTitle: String
        }
        
        internal init(headerView: DetailAccountComponent.ViewModel.HeaderViewModel) {
            self.headerView = headerView
        }
    }
}

struct DetailAccountComponent: View {
    
    @ObservedObject var viewModel: DetailAccountComponent.ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                
                Text(viewModel.headerView.title)
                    .font(.system(size: 20))
                
                Spacer()
                
                Button {
                    
                } label: {
                    
                    Image.ic24ChevronDown
                        .foregroundColor(.white)
                }

            }
            
            Text(viewModel.headerView.subTitle)
                .font(.system(size: 14))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.mainColorsBlack)
        .cornerRadius(12)
    }
}

struct DetailAccountComponent_Previews: PreviewProvider {
    static var previews: some View {
        DetailAccountComponent(viewModel: .sample)
    }
}

extension DetailAccountComponent.ViewModel {
    
    static let sample = DetailAccountComponent.ViewModel(headerView: .init(subTitle: "Поздравляем 🎉, Вы стали обладателем кредитной карты. Оплачивайте покупки и получайте Кешбэк и скидки от партнеров."))
}
