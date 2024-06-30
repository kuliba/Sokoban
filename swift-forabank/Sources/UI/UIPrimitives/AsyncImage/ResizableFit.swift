//
//  ResizableFit.swift
//  
//
//  Created by Igor Malyarov on 30.06.2024.
//

import SwiftUI

public struct ResizableFit: View {
    
    let image: Image
    
    public init(image: Image) {
     
        self.image = image
    }
    
    public var body: some View {
        
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
