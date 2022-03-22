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
        
        NavigationView {
            
            ZStack {
                VStack {
                    
                    Image("Substrate Deposit")
                        .resizable()
                        .frame(height: 248)
                        .edgesIgnoringSafeArea(.all)
                }
                ScrollView {
                    
                    //                             HeaderView(viewModel: viewModel)
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 32) {
                            
                            ProfileCardViewComponent(viewModel: viewModel.productViewModel, currentItem: viewModel.productViewModel.products[0])
                            
                            ProfileButtonsSectionView(viewModel: viewModel.buttonsViewModel)
                            
                            HistoryViewComponent(viewModel: viewModel.historyViewModel)
                        }
                    }
                }
            }
            .navigationBarTitle("title", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle(Text(                viewModel.productViewModel.products[0].name), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                
            }, label: {
                
                Image.ic24ChevronLeft
                
            }), trailing: Button(action: {
                
            }, label: {
                
                Image.ic24Edit2
            }) )
            .navigationBarBackButtonHidden(true)
            //                                .foregroundColor(viewModel.productViewModel.products[0].appearance.textColor)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProfileView(viewModel: .sample)
    }
}


extension ProfileViewModel {
    
    static let sample = ProfileViewModel(productViewModel: .init(products: [.notActivateProfile, .accountProfile, .classicProfile, .blockedProfile]), buttonsViewModel: .sample, historyViewModel: .init( dateOperations: [.init(date: "12 декабря", operations: [.init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)])], spending: .init(value: [100, 300])))
}
