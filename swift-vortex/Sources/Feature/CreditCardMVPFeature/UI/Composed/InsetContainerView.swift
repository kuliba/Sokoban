//
//  InsetContainerView.swift
//
//
//  Created by Igor Malyarov on 30.03.2025.
//

import SwiftUI
import UIPrimitives
import VortexTools

struct InsetContainerView<Content: View, Header: View, Footer: View>: View {
    
    @State private var isScrolling = false
    
    @StateObject var model: ReactiveRefreshScrollViewModel
    
    let content: () -> Content
    let header: (Bool) -> Header
    let footer: () -> Footer
    
    var body: some View {
        
        ReactiveRefreshScrollView(model: model) { offset in
            
            content()
                .onChange(of: offset) { isScrolling = $0 < -0.1 }
        }
        .ignoresSafeArea(.container, edges: .top)
        .safeAreaInset(edge: .top, spacing: 0, content: _header)
        .safeAreaInset(edge: .bottom, spacing: 0, content: footer)
    }
}

private extension InsetContainerView {
    
    func _header() -> some View {
        
        header(isScrolling)
    }
}

// MARK: - Previews

struct InsetContainerView_Demo: View {
    
    let subtitle: String?
    
    var body: some View {
        
        InsetContainerView(model: .preview) {
            
            VStack(spacing: 0) {
                
                Color.blue.opacity(0.4).height(400)
                
                Color.green.height(600)
            }
            
        } header: {
            
            HeaderView(
                title: $0 ? "Credit Card" : "",
                subtitle: $0 ? subtitle : nil,
                action: { print("back button tapped") },
                config: .preview
            )
            .background(Material.thin.opacity($0 ? 1 : 0))
            .background(.orange.opacity($0 ? 0 : 0.4))
            .animation(.easeInOut, value: $0)
            
        } footer: {
            
            Button("Tap me") {}
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.top, 9)
            // .background(Material.thick)
                .background(.pink.opacity(0.5))
        }
    }
}

#Preview {
    
    InsetContainerView_Demo(subtitle: nil)
}

#Preview {
    
    InsetContainerView_Demo(subtitle: "All-Inclisive")
}

#Preview {
    
    InsetContainerView_Demo(subtitle: "All-Inclisive")
        .preferredColorScheme(.dark)
}

private extension ReactiveRefreshScrollViewModel {
    
    static let preview = ReactiveRefreshScrollViewModel(
        config: .preview,
        scheduler: .main,
        refresh: { print("refresh called") }
    )
}


private extension HeaderViewConfig {
    
    static let preview: Self = .init(
        backImage: .init(
            image: .init(systemName: "chevron.left"),
            color: .primary,
            frame: .init(width: 24, height: 24)
        ),
        height: 48,
        hPadding: 16,
        title: .init(textFont: .headline, textColor: .primary),
        subtitle: .init(textFont: .subheadline, textColor: .secondary),
        vSpacing: 4
    )
}

extension SwipeToRefreshConfig {
    
    static let preview: Self = .init(threshold: 100, debounce: .seconds(1))
}
