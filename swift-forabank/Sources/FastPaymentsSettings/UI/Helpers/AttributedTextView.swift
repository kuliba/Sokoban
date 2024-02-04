//
//  AttributedTextView.swift
//
//
//  Created by Igor Malyarov on 04.02.2024.
//

import SwiftUI

#warning("move to UIPrimitives")
struct AttributedTextView: View {
    
    let attributedString: NSAttributedString
    
    var body: some View {
        
        attributedTextView()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func attributedTextView() -> some View {
        
        if #available(iOS 15, *) {
            Text(AttributedString(attributedString))
        } else {
#warning("extract with own preview")
            GeometryReader { geometry in
                
                AttributedText(attributedString: attributedString)
                    .frame(width: geometry.size.width)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct AttributedText: UIViewRepresentable {
    
    var attributedString: NSAttributedString
    
    func makeUIView(context: Context) -> UILabel {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        
        uiView.attributedText = attributedString
    }
}

struct AttributedTextView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AttributedTextView(attributedString: .consent)
    }
}
