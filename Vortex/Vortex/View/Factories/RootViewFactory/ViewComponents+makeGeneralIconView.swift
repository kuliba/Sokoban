//
//  ViewComponents+makeGeneralIconView.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.02.2025.
//

import UIPrimitives

extension ViewComponents {
    
    @inlinable
    func makeGeneralIconView(
        md5Hash: String
    ) -> UIPrimitives.AsyncImage {
        
        return makeGeneralIconView(.md5Hash(.init(md5Hash)))
    }
}
