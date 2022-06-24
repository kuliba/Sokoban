//
//  CollapsableSectionView.swift
//  ForaBank
//
//  Created by Max Gribov on 04.03.2022.
//

import SwiftUI

struct CollapsableSectionView<Content: View>: View {
    
    let title: String
    let isEnabled: Bool
    let edges: Edge.Set
    let padding: CGFloat?

    @Binding var isCollapsed: Bool
    var content: () -> Content
    
    init(title: String, edges: Edge.Set = [], padding: CGFloat? = nil, isEnabled: Bool = true, isCollapsed: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        
        self.title = title
        self.isEnabled = isEnabled
        self.edges = edges
        self.padding = padding
        self._isCollapsed = isCollapsed
        self.content = content
    }
    
    var body: some View {
        
        VStack(spacing: 16) {

            if isEnabled {
                
                HStack(alignment: .center, spacing: 4) {

                    Text(title)
                        .font(.textH2SB20282())
                        .foregroundColor(.textSecondary)

                    Image.ic24ChevronDown
                        .rotationEffect(isCollapsed ? .degrees(-90) : .degrees(0))
                        .foregroundColor(.iconGray)

                    Spacer()
                    
                }
                .padding(edges, padding)
                .onTapGesture {
                    
                    withAnimation {

                        isCollapsed.toggle()
                    }
                }

            } else {

                HStack(alignment: .center, spacing: 4) {

                    Text(title)
                        .font(.textH2SB20282())
                        .foregroundColor(.textDisabled)

                    Image.ic24ChevronDown
                        .foregroundColor(.iconGray)

                    Spacer()

                }.padding(edges, padding)
            }

            if isCollapsed == false {
                
                content()
            }
        }
    }
}

struct CollapsableSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
       
        Group {
            
            CollapsableSectionView(title: "Мои продукты", isCollapsed: .constant(false)) {
                
                Color.gray
            }
            .previewLayout(.fixed(width: 375, height: 150))
            
            CollapsableSectionView(title: "Мои продукты", isCollapsed: .constant(true)) {
                
                Color.gray
            }
            .previewLayout(.fixed(width: 375, height: 150))
        }
    }
}
