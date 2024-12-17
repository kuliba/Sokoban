//
//  MessageTextView.swift
//  ForaBank
//
//  Created by Дмитрий on 26.07.2022.
//

import Foundation
import SwiftUI

struct MessageTextView: UIViewRepresentable {
    
    @State var text: String
    var font: UIFont? = UIFont(name: "Inter-Regular", size: 14)
    var textColor: UIColor = .black
    var linkColor: UIColor = .systemBlue
    let onLinkTap: (URL) -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.font = font
        textView.textColor = textColor
        textView.autocapitalizationType = .sentences
        textView.textAlignment = .center

        textView.linkTextAttributes = [.foregroundColor: linkColor]
        textView.isSelectable = true
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = [.address, .link, .phoneNumber]
        textView.textContainerInset = .zero
        
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        var parent: MessageTextView
        
        init(_ parent: MessageTextView) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
          
            parent.onLinkTap(URL)
            return false
        }
    }
    
    static func calculatedHeight(for text: String, width: CGFloat, font: UIFont? = UIFont(name: "Inter-Regular", size: 14)) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width,
                                          height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = text
        label.textAlignment = .center
        label.sizeToFit()
        label.font = font
        
        let attributedString = NSMutableAttributedString(string: text)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        
        mutableParagraphStyle.lineSpacing = 20
        let stringLength = text.count
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        
        label.attributedText = attributedString
        
        return label.frame.height
    }
}
