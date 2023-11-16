//
//  HintView.swift
//  
//
//  Created by Andryusina Nataly on 25.07.2023.
//

import SwiftUI

struct HintView: View {
    
    var body: some View {
        
        HStack(alignment: .center) {
            
            Text("Не используйте 4 цифры подряд, 4 или 3 одинаковые цифры или парное сочетание цифр ")
                .fixedSize(horizontal: false, vertical: true)
                .font(Font.custom("Inter", size: 14))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 76)
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
        .cornerRadius(12)
    }
}

struct HintView_Previews: PreviewProvider {
    static var previews: some View {
        HintView()
    }
}
