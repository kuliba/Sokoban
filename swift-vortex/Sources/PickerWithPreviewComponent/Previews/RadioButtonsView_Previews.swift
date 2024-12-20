//
//  RadioButtonsView_Previews.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

import SwiftUI

struct RadioButtonsView_Previews: PreviewProvider {
    
    private struct RadioButtonDemo: View {
                
        @State private var selection: OptionWithMapImage
        
        init(selection: OptionWithMapImage) {
            self.selection = selection
        }
        
        var body: some View {
            VStack(alignment: .trailing) {
                RadioButtonsView(
                    checkUncheckImage: .`default`,
                    selection: selection, options: .allWithHtml, viewConfig: .`defaulf`) {
                        
                        selection = $0
                    }
            }
        }
    }
    
    static var previews: some View {
        
        RadioButtonDemo(selection: OptionWithMapImage.oneWithHtml)
        RadioButtonDemo(selection: OptionWithMapImage.twoWithHtml)
        RadioButtonDemo(selection: OptionWithMapImage.threeWithHtml)
    }
}
