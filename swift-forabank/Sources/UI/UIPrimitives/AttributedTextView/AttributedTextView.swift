//
//  AttributedTextView.swift
//
//
//  Created by Igor Malyarov on 04.02.2024.
//

import SwiftUI

public struct AttributedTextView: View {
    
    private let attributedString: NSAttributedString
    private let linkColor: Color
    
    public init(
        attributedString: NSAttributedString,
        linkColor: Color
    ) {
        self.attributedString = attributedString
        self.linkColor = linkColor
    }
    
    public var body: some View {
        
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

extension NSAttributedString {
    
    static var consent: NSAttributedString {
        
        makeHyperlinkedString(
            .consentMessage,
            linkString: "условиями",
            url: .init(string: .consentLink)!
        )
    }
    
    static func makeHyperlinkedString(
        _ fullString: String,
        linkString: String,
        url: URL
    ) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: fullString)
        
        if let hyperlinkRange = fullString.range(of: linkString) {
            
            let nsRange = NSRange(hyperlinkRange, in: fullString)
            attributedString.addAttribute(.link, value: url, range: nsRange)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        }
        
        return attributedString
    }
}

private extension String {
    
    static var consentMessage: Self {
        
        "Подключая возможность осуществлять переводы денежных средств в рамках СБП, соглашаюсь с условиями осуществления переводов СБП"
    }
    
    static var consentLink: Self {
        
        "https://www.forabank.ru/user-upload/sbpay/Usloviya-osuschestvleniya-perevodov-klientov.pdf"
    }
}
