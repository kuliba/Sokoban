//
//  LinkableText.swift
//  
//
//  Created by Igor Malyarov on 31.08.2023.
//

import Foundation

public struct LinkableText {
    
    public let splits: [Split]
    
    public typealias Tag = (prefix: String, suffix: String)
    
    /// Create `LinkableText` with one link.
    /// At most one link: link creation might fail if text has no matching tags,
    /// or URL cannot be created with provided `urlString`.
    
    /// - Parameters:
    ///   - text: A text with links marked with tags.
    ///   - urlString: URL string to construct link.
    ///   - tag: A Tag - a pair of string denoting start and end of the link inside text.
    ///
    ///   If tag occurs multiple time in the text only the first one would be considered.
    public init(text: String, urlString: String, tag: Tag) {
        
        self.init(text: text, urlStrings: [urlString], tag: tag)
    }
        
    public init(text: String, urlStrings: [String], tag: Tag) {
        
        var splits = [Split]()
        var urlStrings = ArraySlice(urlStrings.reversed())
        
        for split in text.split(with: tag) {
            
            switch split {
            case let .insideTag(insideTag):
                
                if let urlString = urlStrings.popLast(),
                   let url = URL(string: urlString) {
                    
                    splits.append(.link(insideTag, url))
                    
                } else {
                    
                    splits.append(.text(insideTag))
                }
                
            case let .outsideTag(outsideTag):
                splits.append(.text(outsideTag))
            }
        }
        
        self.splits = splits
    }
    
    public enum Split: Hashable {
        
        case text(String)
        case link(String, URL)
    }
}
