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

//MARK: - Preview

struct ContactsView_Previews: PreviewProvider {

    static var previews: some View {

        Group {
            
            ContactsView(viewModel: .sampleFastContacts)
            
            ContactsView(viewModel: .sampleFastBanks)
        }
    }
}

//MARK: - Preview Content

extension ContactsViewModel {
    
    static let sampleFastContacts = ContactsViewModel(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(.contacts)), visible: [ContactsLatestPaymentsSectionViewModel.sample, ContactsListSectionViewModel.sample], sections: [], mode: .fastPayments(.contacts))
    
    static let sampleFastBanks = ContactsViewModel(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(.contacts)), visible: [ContactsBanksPrefferedSectionViewModel.sample, ContactsBanksSectionViewModel.sample, ContactsCountriesSectionViewModel.sample], sections: [], mode: .fastPayments(.contacts))
}
