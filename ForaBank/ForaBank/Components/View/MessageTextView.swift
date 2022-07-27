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

        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
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
