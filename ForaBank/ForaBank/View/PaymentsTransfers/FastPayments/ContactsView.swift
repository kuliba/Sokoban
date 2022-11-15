//
//  ContactsView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import SwiftUI

struct ContactsView: View {
    
    @ObservedObject var viewModel: ContactsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                
                SearchBarView(viewModel: viewModel.searchBar)
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ForEach(viewModel.visible) { section in
                
                switch section {
                case let latestPaymentsViewModel as ContactsLatestPaymentsSectionViewModel:
                    ContactsLatestPaymentsSectionView(viewModel: latestPaymentsViewModel)
                    
                case let contactsSectionViewModel as ContactsListSectionViewModel:
                    ContactsListSectionView(viewModel: contactsSectionViewModel)
                    
                case let banksPrefferedViewModel as ContactsBanksPrefferedSectionViewModel:
                    ContactsBanksPrefferedSectionView(viewModel: banksPrefferedViewModel)
                    
                case let banksViewModel as ContactsBanksSectionViewModel:
                    ContactsBanksSectionView(viewModel: banksViewModel)
                    
                case let countriesViewModel as ContactsCountriesSectionViewModel:
                    ContactsCountriesSectionView(viewModel: countriesViewModel)
                    
                default:
                    EmptyView()
                }
            }

            Spacer()
            
        }.ignoresSafeArea(.all, edges: .bottom)
    }
}


struct ContactsView_Previews: PreviewProvider {

    static var previews: some View {

        Group {
/*
            ContactsView.CollapsableView.HeaderView(viewModel: .init(header: .init(icon: .ic40SBP, title: "В другой банк", toggleButton: ContactsSectionCollapsableViewModel.HeaderViewModel.ButtonViewModel(icon: .ic24ChevronUp, action: {})), items: [.sampleItem], model: .emptyMock))
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("HeaderView")

            ContactsView.CollapsableView(viewModel: ContactsBanksSectionViewModel(.emptyMock, header: .sampleHeader, items: [.sampleItem], mode: .normal, options: .sample))
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("CollapsableView")
*/
            /*
            ContactsView(viewModel: .sample)
                .previewDisplayName("Contacts List")

            ContactsView(viewModel: .sampleLatestPayment)
                .previewDisplayName("Contacts List")
             */
        }
    }
}
