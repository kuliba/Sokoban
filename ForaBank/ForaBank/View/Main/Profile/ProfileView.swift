//
//  ProfileView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        
        VStack {
            
            HStack {
            
//                Text(viewModel.productViewModel.products[0].name)
            }
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    
                    ZStack(alignment: .top) {
                        
                        VStack {
                            
                            ProfileCardViewComponent(viewModel: .init(products: [.classic], product: .classic, moreButton: true))
                        }
                    }
                    .background( viewModel.productViewModel.product.appearance.background.image, alignment: .top)
                    .edgesIgnoringSafeArea(.top)
                    
                    ProfileButtonsSectionView(viewModel: .init(kind: viewModel.productViewModel.product.productType, debit: true, credit: true))
                    
                    if let detailAccount = viewModel.detailAccountViewModel {
                        
                        DetailAccountViewComponent(viewModel: detailAccount)
                            .padding(.horizontal, 20)
                    }
                    
                    HistoryViewComponent(viewModel: viewModel.historyViewModel ?? .init(dateOperations: [.init(date: "", operations: [.init(title: "", image: .ic16Sun, subtitle: "", amount: "", type: .debit)])], spending: nil))
                }
            }
            .navigationBarTitle("title", displayMode: .inline)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProfileView(viewModel: .sample)
    }
}


extension ProfileViewModel {
    
    static let sample = ProfileViewModel(productViewModel: .init(products: [.notActivateProfile, .accountProfile, .classicProfile, .blockedProfile], product: .classicProfile, moreButton: true), historyViewModel: .init( dateOperations: [.init(date: "12 декабря", operations: [.init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)])], spending: .init(value: [100, 300])), model: .emptyMock)
}
