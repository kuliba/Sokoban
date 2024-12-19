
import Foundation
import SwiftUI
import UIKitHelpers

struct RadioButtonsView: View {
    
    let checkUncheckImage: CheckUncheckImages
    let selection: OptionWithMapImage
    let options: [OptionWithMapImage]
    
    let viewConfig: PickerWithPreviewContainerView.ViewConfig
    
    let select: (OptionWithMapImage) -> Void
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 0)  {
            
            ForEach(options, content: optionView)
                .animation(.default, value: selection)
        }
    }
    
    private func optionView(option: OptionWithMapImage) -> some View {
        
        VStack (spacing: 0) {
            
            HStack (alignment: .center) {
                
                option == selection ? checkUncheckImage.checkedImage : checkUncheckImage.uncheckedImage
                
                
                AttributedLabel(html: option.title)
            }
            .frame(maxHeight: 72)
            .onTapGesture(perform: {
                
                select(option)
            })
            if option.id != options.last?.id {
                
                Divider()
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 6))
            }
        }
    }
}
