//
//  ShareSheetPayload.swift
//
//
//  Created by Igor Malyarov on 18.02.2025.
//

/// A payload for the share sheet that contains the items to be shared.
public struct ShareSheetPayload {
    
    /// The items to share (text, URLs, images, etc.).
    public let items: [Any]
    
    /// Creates a new payload with the provided items.
    ///
    /// - Parameter items: An array of items to share.
    public init(items: [Any]) {
        
        self.items = items
    }
}
