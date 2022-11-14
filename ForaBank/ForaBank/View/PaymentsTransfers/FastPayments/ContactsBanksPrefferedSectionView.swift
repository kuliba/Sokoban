//
//  ContactsBanksPrefferedSectionView.swift
//  ForaBank
//
//  Created by Max Gribov on 14.11.2022.
//

import SwiftUI

struct ContactsBanksPrefferedSectionView: View {
    
    @ObservedObject var viewModel: ContactsBanksPrefferedSectionViewModel
    
    var body: some View {
       
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 8) {
                
                ForEach(viewModel.items) { item in
                   
                    switch item {
                    case let prefferedBank as ContactsBankPrefferedItemView.ViewModel:
                        ContactsBankPrefferedItemView(viewModel: prefferedBank)
                        
                    case let placeholderViewModel as ContactsPlaceholderItemView.ViewModel:
                        ContactsPlaceholderItemView(viewModel: placeholderViewModel)
                    
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct ContactsBanksPrefferedSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContactsBanksPrefferedSectionView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension ContactsBanksPrefferedSectionViewModel {
    
    static let sample = ContactsBanksPrefferedSectionViewModel(items: [ContactsBankPrefferedItemView.ViewModel.sample], phone: nil, mode: .fastPayment, model: .emptyMock)
    
}
