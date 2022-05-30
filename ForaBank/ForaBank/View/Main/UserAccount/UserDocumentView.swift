//
//  UserDocumentView.swift
//  ForaBank
//
//  Created by Mikhail on 29.05.2022.
//

import SwiftUI

struct UserDocumentView: View {
    
    @ObservedObject var viewModel: UserDocumentViewModel
    
    var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                ZStack {
                    
                    viewModel.itemType.viewModel.background
                        .frame(height: 56)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .foregroundColor(viewModel.itemType.viewModel.iconBackground)
                            .frame(width: 64, height: 64)
                        
                        viewModel.itemType.viewModel.icon
                            .resizable()
                            .frame(width: 39, height: 39)
                            .foregroundColor(.iconWhite)
                    }
                    .offset(x: 0, y: 28)
                }
                .padding(.bottom, 28)
                
                VStack(spacing: 24) {
                    
                    ForEach(viewModel.items) { item in
                        
                        DocumentDelailCellView(viewModel: item)
                        
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            
            VStack {
                
                Spacer()
                
                GrayButtonView(viewModel: viewModel.copyButton)
                    .frame(height: 48)
                    .padding(20)
            }
        }
        .navigationBarTitle(
            Text(viewModel.navigationBar.title).font(.textH3M18240()),
            displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: backButton,
            trailing: settingButton)
    }
    
    var backButton: some View {
        
        Button {
            viewModel.navigationBar.backButton.action()
        } label: {
            viewModel.navigationBar.backButton.icon
                .foregroundColor(.iconBlack)
        }
    }
    
    var settingButton: some View {
        
        Button {
            viewModel.navigationBar.rightButton.action()
        } label: {
            viewModel.navigationBar.rightButton.icon
                .foregroundColor(.iconGray)
        }
    }
    
}

struct UserDocumentView_Previews: PreviewProvider {
    
    static var previews: some View {
    
        UserDocumentView(viewModel: .init(
            model: Model.emptyMock,
            navigationBar: .sample,
            items: DocumentDelailCellView.ViewModel.exampleArr,
            itemType: .passport))
    }
}
