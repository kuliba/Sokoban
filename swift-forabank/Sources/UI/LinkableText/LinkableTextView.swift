//
//  LinkableTextView.swift
//  
//
//  Created by Igor Malyarov on 31.08.2023.
//

import SwiftUI

public struct LinkableTextView: View {
    
    let linkableText: LinkableText
    let handleURL: (URL) -> Void
    
    public init(
        taggedText text: String,
        urlString: String,
        tag: LinkableText.Tag = ("<u>", "</u>"),
        handleURL: @escaping (URL) -> Void
    ) {
        self.init(
            linkableText: .init(text: text, urlString: urlString, tag: tag),
            handleURL: handleURL
        )
    }
    
    public init(
        linkableText: LinkableText,
        handleURL: @escaping (URL) -> Void
    ) {
        self.linkableText = linkableText
        self.handleURL = handleURL
    }
    
    public var body: some View {
        
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            
            ForEach(linkableText.splits, id: \.self, content: splitView)
        }
    }
    
    @ViewBuilder
    private func splitView(split: LinkableText.Split) -> some View {
        
        switch split {
        case let .text(string):
            Text(string)
            
        case let .link(string, url):
            Button {
                handleURL(url)
            } label: {
                Text(string)
                    .underline()
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 16, content: previewsGroup)
    }
    
    private static func previewsGroup() -> some View {
        
        Group {
            
            linkableTextView(text: "", urlString: " ")
            linkableTextView(text: "", urlString: "abc")
            linkableTextView(text: "Very <u>important</u> message.", urlString: "abc")
            linkableTextView(text: "Very <i>important</i> message.", urlString: "abc")
            linkableTextView(text: "<u>important</u> message.", urlString: "abc")
            linkableTextView(text: "Very <u>important</u>", urlString: "abc")
        }
        .accentColor(.orange)
    }
    
    private static func linkableTextView(
        text: String,
        urlString: String
    ) -> some View {
        
        LinkableTextView(
            taggedText: text,
            urlString: urlString,
            tag: ("<u>", "</u>"),
            handleURL: { _ in }
        )
    }
}
