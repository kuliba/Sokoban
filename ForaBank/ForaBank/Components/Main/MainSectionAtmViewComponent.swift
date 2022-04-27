//
//  MainSectionAtmViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 27.04.2022.
//

import Foundation
import Combine
import SwiftUI

//MARK: - ViewModel

extension MainSectionAtmView {

    class ViewModel: MainSectionCollapsableViewModel {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        override var type: MainSectionType { .atm }
        let content: String
        
        internal init(content: String, isCollapsed: Bool) {
            
            self.content = content
            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - Action

enum MainSectionAtmViewModelAction {

    struct ButtonTapped: Action {}
}

//MARK: - View

struct MainSectionAtmView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        MainSectionCollapsableView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            Button {
                
                viewModel.action.send(MainSectionAtmViewModelAction.ButtonTapped())
                
            } label: {
                
                ZStack(alignment: .leading) {
                    
                    Image.imgMainMap
                    
                    Text(viewModel.content)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                        .frame(width: 100)
                        .lineSpacing(6)
                        .padding(.leading, 12)
                }
            }
        }
    }
}

//MARK: - Preview

struct MainBlockAtmView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionAtmView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionAtmView.ViewModel {
    
    static let sample = MainSectionAtmView.ViewModel(content: "Выберите ближайшую точку на карте", isCollapsed: false)

}

