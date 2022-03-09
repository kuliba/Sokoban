//
//  MainSectionCollapsableView.swift
//  ForaBank
//
//  Created by Max Gribov on 04.03.2022.
//

import SwiftUI

struct MainSectionCollapsableView<Content: View>: View {
    
    let title: String
    @Binding var isCollapsed: Bool
    var content: () -> Content
    
    init(title: String, isCollapsed: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        
        self.title = title
        self._isCollapsed = isCollapsed
        self.content = content
    }
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            Button {

                withAnimation {
                    
                    isCollapsed.toggle()
                }

            } label: {

                HStack(alignment: .center, spacing: 4) {

                    Text(title)
                        .font(.textH2SB20282())
                        .foregroundColor(.textSecondary)
                    
                    Image.ic24ChevronDown
                        .rotationEffect(isCollapsed ? .degrees(-90) : .degrees(0))
                        .foregroundColor(.iconGray)

                    Spacer()
                }
            }

            if isCollapsed == false {
                
                content()
            }
        }
    }
}

struct MainSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
       
        Group {
            
            MainSectionCollapsableView(title: "Мои продукты", isCollapsed: .constant(false)) {
                
                Color.gray
            }
            .previewLayout(.fixed(width: 375, height: 150))
            
            MainSectionCollapsableView(title: "Мои продукты", isCollapsed: .constant(true)) {
                
                Color.gray
            }
            .previewLayout(.fixed(width: 375, height: 150))
        }
    }
}
