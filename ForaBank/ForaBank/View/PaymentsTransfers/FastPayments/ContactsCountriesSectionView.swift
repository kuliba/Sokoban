//
//  ContactsCountriesSectionView.swift
//  ForaBank
//
//  Created by Max Gribov on 15.11.2022.
//

import SwiftUI

struct ContactsCountriesSectionView: View {
    
    @ObservedObject var viewModel: ContactsCountriesSectionViewModel
    
    var body: some View {
        
        switch viewModel.mode {
        case .fastPayment:
            
            ContactsSectionHeaderView(viewModel: viewModel.header)
            
            if viewModel.header.isCollapsed {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(spacing: 24) {
                        
                        ForEach(viewModel.items) { item in
                            
                            switch item {
                            case let countryItemViewModel as ContactsCountryItemView.ViewModel:
                                ContactsCountryItemView(viewModel: countryItemViewModel)
                                
                            case let placeholderViewModel as ContactsPlaceholderItemView.ViewModel:
                                ContactsPlaceholderItemView(viewModel: placeholderViewModel)
                                
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)

            }
            
        case .select:
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 24) {
                    
                    ForEach(viewModel.items) { item in
                        
                        switch item {
                        case let countryItemViewModel as ContactsCountryItemView.ViewModel:
                            ContactsCountryItemView(viewModel: countryItemViewModel)
                            
                        case let placeholderViewModel as ContactsPlaceholderItemView.ViewModel:
                            ContactsPlaceholderItemView(viewModel: placeholderViewModel)
                            
                        default:
                            EmptyView()
                        }
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
        }
    }
}

//MARK: - Preview

struct ContactsCountriesSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContactsCountriesSectionView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension ContactsCountriesSectionViewModel {
    
    static let sample = ContactsCountriesSectionViewModel(header: .init(kind: .country), isCollapsed: false, mode: .fastPayment, items: [ContactsCountryItemView.ViewModel.sample], model: .emptyMock)
}
