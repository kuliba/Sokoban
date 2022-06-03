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
        
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                
                ZStack {
                    
                    GeometryReader { geometry in
                        
                        ZStack {
                            
                            BackgroundHeaderView(geometry: geometry, color: viewModel.itemType.backgroundColor)
                            
                        }
                    }
                    .frame(height: 100)
                }
                
                VStack(spacing: 24) {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 32)
                            .foregroundColor(viewModel.itemType.iconBackground)
                            .frame(width: 64, height: 64)
                        
                        viewModel.itemType.icon
                            .resizable()
                            .frame(width: 39, height: 39)
                            .foregroundColor(.iconWhite)
                    }
                    
                    ForEach(viewModel.items) { item in
                        
                        DocumentDelailCellView(viewModel: item)
                        
                    }
                }
                .offset(x: 0, y: -40)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .edgesIgnoringSafeArea(.top)
            }
            
            ZStack {
                
                viewModel.itemType.backgroundColor
                    .contrast(0.8)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: 50)
                
                NavigationBarView
            }
            
            VStack {
                
                Spacer()
                
                ButtonSimpleView(viewModel: viewModel.copyButton)
                    .frame(height: 48)
                    .padding(20)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
        
    var NavigationBarView: some View {
        
        HStack {
            
            Button {
                
                viewModel.navigationBar.backButton.action()
                
            } label: {
                
                viewModel.navigationBar.backButton.icon
                    .foregroundColor(.iconWhite)
            }
            
            Spacer()
            
            VStack {
                
                Text(viewModel.navigationBar.title)
                    .font(.textH3M18240())
                    .foregroundColor(.iconWhite)
            }
            
            Spacer()
            
            Button {
                
                viewModel.navigationBar.rightButton.action()
                
            } label: {
                
                viewModel.navigationBar.rightButton.icon
                    .foregroundColor(.iconWhite)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .background(Color.clear)
    }
    
    struct BackgroundHeaderView: View {
        
        let geometry: GeometryProxy
        let color: Color
        
        var body: some View {
            
            if geometry.frame(in: .global).minY <= 0 {
                
                Rectangle()
                    .foregroundColor(color)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(y: geometry.frame(in: .global).minY)
                    .clipped()
                
            } else {
                
                Rectangle()
                    .foregroundColor(color)
                    .frame(width: geometry.size.width, height: geometry.size.height + geometry.frame(in: .global).minY)
                    .clipped()
                    .offset(y: -geometry.frame(in: .global).minY)
            }
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
