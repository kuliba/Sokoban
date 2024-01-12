//
//  InformerView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import SwiftUI

struct InformerView: View {
    
    let text: String
    
    var body: some View {
        
        Text(text)
            .multilineTextAlignment(.leading)
            .padding()
            .foregroundColor(.white)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}

struct InformerView_Previews: PreviewProvider {
    
    static var previews: some View {
 
        InformerView(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
    }
}
