//
//  AttributedLabel.swift
//  
//
//  Created by Andryusina Nataly on 04.06.2023.
//

import UIKit
import SwiftUI

public struct AttributedLabel: UIViewRepresentable {
    
    private let html: String
    
    public init(
        html: String
    ) {
        self.html = html
    }
    
    public func makeUIView(context: Context) -> UITextView {
        
        let view = UITextView()
        view.textContainer.lineFragmentPadding = 0
        Task { @MainActor in
            
            let attributedString = html.htmlStringToAttributedString
            view.attributedText = attributedString
        }
        view.isScrollEnabled = false
        view.isEditable = false
        view.isUserInteractionEnabled = true
        view.backgroundColor = .init(Color.clear)
        
        return view
    }
    
    public func updateUIView(_ uiView: UITextView, context: Context) {
        
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}
