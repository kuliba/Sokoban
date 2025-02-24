//
//  ViewComponents+infoView.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.02.2025.
//

import PaymentComponents
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func infoViewNoIcon(
        info: Info,
        config: InfoConfig = .iVortex
    ) -> some View {
        
        PaymentComponents.InfoView(
            info: info,
            config: config
        )
    }
    
    @inlinable
    func infoView<Icon: View>(
        info: Info,
        config: InfoConfig = .iVortex,
        icon: @escaping () -> Icon
    ) -> some View {
        
        PaymentComponents.InfoView(
            info: info,
            config: config,
            icon: icon
        )
    }
    
    @inlinable
    func infoView<Icon: View>(
        info: Info,
        config: InfoConfig = .iVortex,
        icon: Icon
    ) -> some View {
        
        PaymentComponents.InfoView(
            info: info,
            config: config,
            icon: { icon }
        )
    }
    
    @inlinable
    func infoView(
        info: Info,
        config: InfoConfig = .iVortex,
        md5Hash: String?
    ) -> some View {
        
        infoView(
            info: info,
            config: config,
            icon: { makeIconView(md5Hash: md5Hash) }
        )
    }
}
