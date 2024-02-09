//
//  InactiveContractView.swift
//
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct InactiveContractView: View {
    
    let action: () -> Void
    let config: InactiveContractConfig
    
    var body: some View {
        
        VStack {
            
            Button(action: action) {
                
                HStack(spacing: 16) {
                    
                    Text("Включить переводы СБП")
                    
                    Spacer()
                    
                    ToggleMockView(status: .inactive)
                }
            }
            
            AttributedTextView(attributedString: .consent)
            
            Spacer()
        }
        .padding()
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

struct InactiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InactiveContractView(
            action: {},
            config: .preview
        )
    }
}
