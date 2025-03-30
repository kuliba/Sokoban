//
//  InsetContainerView.swift
//
//
//  Created by Igor Malyarov on 30.03.2025.
//

import CombineSchedulers
import SwiftUI
import UIPrimitives
import VortexTools

struct InsetContainerWrapperView<Content: View, Header: View, Footer: View>: View {
    
    let config: SwipeToRefreshConfig
    let scheduler: AnySchedulerOf<DispatchQueue>
    let refresh: () -> Void
    let content: () -> Content
    let header: (Bool) -> Header
    let footer: () -> Footer
    
    var body: some View {
        
        LazyModelView(
            factory: {
                
                .init(config: config, scheduler: scheduler, refresh: refresh)
            },
            content: {
                
                InsetContainerView(model: $0, content: content, header: header, footer: footer)
            }
        )
    }
}

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
        .safeAreaInset(edge: .top, spacing: 0) { header(isScrolling) }
        .safeAreaInset(edge: .bottom, spacing: 0, content: footer)
    }
}

// MARK: - Previews

#Preview {
    
    InsetContainerWrapperView(
        config: .preview,
        scheduler: .main,
        refresh: { print("refresh called") },
        content: _content,
        header: { _header(isScrolling: $0, subtitle: "All-Inclisive") },
        footer: _footer
    )
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

struct InsetContainerView_Demo: View {
    
    let subtitle: String?
    
    var body: some View {
        
        InsetContainerView(
            model: .preview,
            content: _content,
            header: { _header(isScrolling: $0, subtitle: subtitle) },
            footer: _footer
        )
    }
}

private func _content() -> some View {
    
    VStack(spacing: 0) {
        
        Color.blue.opacity(0.4).height(400)
        
        Color.orange.height(600)
    }
    
}

private func _header(isScrolling: Bool, subtitle: String?) -> some View {
    
    HeaderView(
        title: isScrolling ? "Credit Card" : "",
        subtitle: isScrolling ? subtitle : nil,
        action: { print("back button tapped") },
        config: .preview
    )
    .background(Material.thin.opacity(isScrolling ? 1 : 0))
    .background(.green.opacity(isScrolling ? 0 : 0.4))
    .animation(.easeInOut, value: isScrolling)
}

private func _footer() -> some View {
    
    Button("Tap me") {}
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
        .padding(.top, 9)
    // .background(Material.thick)
        .background(.pink.opacity(0.5))
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
