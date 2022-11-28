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
       
        VStack(spacing: 16) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(alignment: .top, spacing: 20) {
                    
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
                    
                }.padding(.horizontal, 20)
            }
            
            if viewModel.items.count > 0 {
                
                Divider()
                    .foregroundColor(Color.mainColorsGrayLightest)
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
    
    static let sample = ContactsBanksPrefferedSectionViewModel(items: [ContactsBankPrefferedItemView.ViewModel.sample, ContactsBankPrefferedItemView.ViewModel.sampleFavorite], phone: nil, mode: .fastPayment, model: .emptyMock)
    
}
