//
//  ContactsBanksSectionView.swift
//  ForaBank
//
//  Created by Max Gribov on 15.11.2022.
//

import SwiftUI

struct ContactsBanksSectionView: View {
    
    @ObservedObject var viewModel: ContactsBanksSectionViewModel
    
    var body: some View {
      
        switch viewModel.mode {
        case .fastPayment:
            
            if let searchBar = viewModel.searchBar {
                
                SearchBarView(viewModel: searchBar)
                    .padding(.horizontal, 20)
                
            } else {
                
                ContactsSectionHeaderView(viewModel: viewModel.header)
            }
            
            if viewModel.header.isCollapsed {
                
                OptionSelectorView(viewModel: viewModel.options)
                    .padding()
                
                ScrollView(.vertical) {
                    
                    VStack(spacing: 24) {
                        
                        ForEach(viewModel.visible) { item in
                            
                            switch item {
                            case let bankItemViewModel as ContactsBankItemView.ViewModel:
                                ContactsBankItemView(viewModel: bankItemViewModel)
                                
                            case let placeholderViewModel as ContactsPlaceholderItemView.ViewModel:
                                ContactsPlaceholderItemView(viewModel: placeholderViewModel)
                                
                            default:
                                EmptyView()
                            }
                        }
               
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 20)
                }
                
               
            }
            
        case .select:
            
            ScrollView(.vertical) {
                
                VStack(spacing: 24) {
                    
                    ForEach(viewModel.visible) { item in
                        
                        switch item {
                        case let bankItemViewModel as ContactsBankItemView.ViewModel:
                            ContactsBankItemView(viewModel: bankItemViewModel)
                            
                        case let placeholderViewModel as ContactsPlaceholderItemView.ViewModel:
                            ContactsPlaceholderItemView(viewModel: placeholderViewModel)
                            
                        default:
                            EmptyView()
                        }
                    }
           
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
            }
        }
    }
}

//MARK: - Preview

struct ContactsBanksSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContactsBanksSectionView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension ContactsBanksSectionViewModel {
    
    static let sample = ContactsBanksSectionViewModel(.emptyMock, header: .init(kind: .banks), isCollapsed: false, mode: .fastPayment, searchBar: nil, options: .sample, visible: [ContactsBankItemView.ViewModel.sample], items: [])
}
