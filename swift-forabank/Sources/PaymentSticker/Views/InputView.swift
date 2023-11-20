//
//  InputView.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import SwiftUI

// MARK: - View

struct InputView: View {
    
    @State private var text = ""
    
    let title: String
    let commit: (String) -> Void
    let configuration: InputConfiguration
    
    var body: some View {
        
        let textField = TextField(title, text: $text)
        
        LabeledView(
            title: title,
            configuration: configuration,
            makeLabel: { textField }
        )
        .onChange(of: text, perform: commit)
    }
}

public struct InputConfiguration {

    let titleFont: Font
    let titleColor: Color
    let iconColor: Color
    let iconName: String
    
    public init(
        titleFont: Font,
        titleColor: Color,
        iconColor: Color,
        iconName: String
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.iconColor = iconColor
        self.iconName = iconName
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
       
        #warning("add previews")
        // ParameterView()
        EmptyView()
    }
}
