//
//  ContactsView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import SwiftUI
import SearchBarComponent

struct ContactsView: View {
    
    @ObservedObject var viewModel: ContactsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text(viewModel.title)
                    .font(.textH3Sb18240())
                
                DefaultCancellableSearchBarView(
                    viewModel: viewModel.searchFieldModel,
                    textFieldConfig: .black16,
                    cancel: viewModel.cancelSearch
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ForEach(viewModel.visible, content: sectionView)
            
            Spacer()
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    @ViewBuilder
    private func sectionView(
        section: ContactsSectionViewModel
    ) -> some View {
        
        switch section {
        case let viewModel as ContactsLatestPaymentsSectionViewModel:
            ContactsLatestPaymentsSectionView(viewModel: viewModel)
                .accessibilityIdentifier("TransferByPhoneLatestPaymentsSection")
            
        case let viewModel as ContactsListSectionViewModel:
            ContactsListSectionView(viewModel: viewModel)
                .accessibilityIdentifier("TransferByPhoneContactsSection")
            
        case let viewModel as ContactsBanksPrefferedSectionViewModel:
            ContactsBanksPrefferedSectionView(viewModel: viewModel)
            
        case let viewModel as ContactsBanksSectionViewModel:
            ContactsBanksSectionView(viewModel: viewModel)
            
        case let viewModel as ContactsCountriesSectionViewModel:
            ContactsCountriesSectionView(viewModel: viewModel)
            
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

struct ContactsView_Previews: PreviewProvider {

    static var previews: some View {

        Group {
            
            ContactsView(viewModel: .sampleFastContacts)
            
            ContactsView(viewModel: .sampleFastBanks)
        }
    }
}
