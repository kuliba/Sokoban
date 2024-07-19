//
//  FilterOptionButtonView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import SwiftUI

struct FilterOptionButtonView: View {
    
    let title: String
    @State var isSelected: Bool
    let tappedAction: () -> Void
    
    var body: some View {
        
        Button {
            
            tappedAction()
            isSelected.toggle()
            
        } label: {
            
            Text(title)
                .foregroundColor(isSelected ? Color.white : Color.black)
                .padding(.vertical, 7.5)
                .padding(.horizontal, 8)
                .background(isSelected ? Color.black : Color.gray.opacity(0.2))
                .cornerRadius(20)
                .frame(alignment: .leading)
        }
    }
}

#Preview {
    
    Group {

        FilterOptionButtonView(
            title: "Списание",
            isSelected: true,
            tappedAction: {}
        )

        FilterOptionButtonView(
            title: "Пополнение",
            isSelected: false,
            tappedAction: {}
        )
    }
}
