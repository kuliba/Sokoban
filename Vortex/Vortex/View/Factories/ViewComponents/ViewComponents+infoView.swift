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
    func infoViewCompressed(
        id: String = UUID().uuidString,
        title: String,
        value: String,
        config: InfoConfig = .iVortex
    ) -> some View {
        
        infoViewNoIcon(
            info: .init(
                id: .other(id),
                title: title,
                value: value,
                style: .compressed
            ),
            config: config
        )
    }
    
    @inlinable
    func infoView(
        id: String = UUID().uuidString,
        icon: Image?,
        title: String,
        value: String,
        config: InfoConfig = .iVortex
    ) -> some View {
        
        infoView(
            info: .init(
                id: .other(id),
                title: title,
                value: value,
                style: .expanded
            ),
            config: config,
            icon: { icon }
        )
    }
    
    @inlinable
    func infoView<Icon: View>(
        id: String = UUID().uuidString,
        icon: Icon,
        title: String,
        value: String,
        config: InfoConfig = .iVortex
    ) -> some View {
        
        infoView(
            info: .init(
                id: .other(id),
                title: title,
                value: value,
                style: .expanded
            ),
            config: config,
            icon: icon
        )
    }
    
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
        @ViewBuilder icon: @escaping () -> Icon
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
