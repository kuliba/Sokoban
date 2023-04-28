//
//  WrappedTextView.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import UIKit

public class WrappedTextView: UITextView {
    
    private var lastWidth: CGFloat = 0
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.width != lastWidth {
            
            lastWidth = bounds.width
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        
        let size = sizeThatFits(CGSize(width: lastWidth, height: UIView.layoutFittingExpandedSize.height))
        
        return CGSize(width: size.width.rounded(.up), height: size.height.rounded(.up))
    }
}
