//
//  UserDocumentView.swift
//  ForaBank
//
//  Created by Mikhail on 29.05.2022.
//

import SwiftUI
import Introspect

struct UserDocumentView: View {
    
    @ObservedObject var viewModel: UserDocumentViewModel
    @State private var tabBarController: UITabBarController?
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                
                ZStack {
                    
                    GeometryReader { geometry in
                        
                        ZStack {
                            
                            BackgroundHeaderView(geometry: geometry, color: viewModel.navigationBar.background)
                            
                        }
                    }
                    .frame(height: 0)
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
                
                viewModel.navigationBar.background
                    .contrast(0.8)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: 50)
                
            }
            
            VStack {
                
                Spacer()
                if let button = viewModel.copyButton {
                    ButtonSimpleView(viewModel: button)
                        .frame(height: 48)
                        .padding(20)
                }
            }
        }
        .navigationBar(with: viewModel.navigationBar)
        .introspectTabBarController(customize: { tabBarController in
            
            self.tabBarController = tabBarController
            tabBarController.tabBar.isHidden = true
            UIView.transition(with: tabBarController.view, duration: 0.05, options: .transitionCrossDissolve, animations: nil)
        })
        .onDisappear {
            
            if let tabBarController = tabBarController {
                
                tabBarController.tabBar.isHidden = false
                UIView.transition(with: tabBarController.view, duration: 0.05, options: .transitionCrossDissolve, animations: nil)
            }
            
        }
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
    
    static let type = DocumentCellType.passport
    
    static let navBar = NavigationBarView.ViewModel(
        title: type.title,
        leftButtons: [
            NavigationBarView.ViewModel.BackButtonViewModel(icon: .ic24ChevronLeft)
        ],
        rightButtons: [
            .init(icon: .ic24Share, action: { })
        ],
        background: type.backgroundColor,
        foreground: .textWhite)
    
    static var previews: some View {
    
        UserDocumentView(viewModel: .init(
            model: Model.emptyMock,
            navigationBar: navBar,
            items: DocumentDelailCellView.ViewModel.exampleArr,
            itemType: .passport))
    }
}
