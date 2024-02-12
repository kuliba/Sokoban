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
    let linkColor: Color
    
    var body: some View {
        
        attributedTextView()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func attributedTextView() -> some View {
        
        if #available(iOS 15, *) {
            Text(AttributedString(modifiedAttributedString()))
        } else {
#warning("extract with own preview")
            GeometryReader { geometry in
                
                AttributedText(attributedString: modifiedAttributedString())
                    .frame(width: geometry.size.width)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func modifiedAttributedString(
    ) -> NSAttributedString {
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        mutableAttributedString.enumerateAttribute(
            .link,
            in: NSRange(
                location: 0,
                length: attributedString.length
            ),
            options: []
        ) { value, range, _ in
            
            if let _ = value as? URL {
                
                let uiColor = UIColor(linkColor)
                mutableAttributedString.addAttribute(.foregroundColor, value: uiColor, range: range)
            }
        }
        
        return mutableAttributedString
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
        
        VStack(spacing: 64) {
 
            AttributedTextView(attributedString: .consent, linkColor: .orange)
                .foregroundColor(.green)
            
            AttributedTextView(attributedString: .consent, linkColor: .gray)
        }
    }
}
