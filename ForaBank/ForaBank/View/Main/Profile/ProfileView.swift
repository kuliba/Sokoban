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
            
                Text(viewModel.productViewModel.products[0].name)
            }
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    
                    ZStack(alignment: .top) {
                        
                        VStack {
                            
                            ProfileCardViewComponent(viewModel: .init(products: viewModel.productViewModel.products, product: viewModel.productViewModel.products[0], moreButton: true))
                        }
                    }
                    .background( Image("Substrate Deposit"), alignment: .top)
                    .edgesIgnoringSafeArea(.top)
                    
                    ProfileButtonsSectionView(viewModel: viewModel.buttonsViewModel)
                    
                    if let detailAccount = viewModel.detailAccountViewModel {
                        
                        DetailAccountViewComponent(viewModel: detailAccount)
                            .padding(.horizontal, 20)
                    }
                    
                    HistoryViewComponent(viewModel: viewModel.historyViewModel)
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
    
    static let sample = ProfileViewModel(productViewModel: .init(products: [.notActivateProfile, .accountProfile, .classicProfile, .blockedProfile], product: .classicProfile, moreButton: true), buttonsViewModel: .sample, detailAccountViewModel: .init(with: .init(), status: .active, isCredit: false, productName: "", longInt: nil), historyViewModel: .init( dateOperations: [.init(date: "12 декабря", operations: [.init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)])], spending: .init(value: [100, 300])), model: .emptyMock)
}
