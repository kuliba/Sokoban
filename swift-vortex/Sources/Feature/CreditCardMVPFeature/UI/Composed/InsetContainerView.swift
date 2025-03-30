//
//  InsetContainerView.swift
//
//
//  Created by Igor Malyarov on 30.03.2025.
//

import SwiftUI
import UIPrimitives

struct InsetContainerView<Content: View, Header: View, Footer: View>: View {
    
    let content: () -> Content
    let header: () -> Header
    let footer: () -> Footer
    
    var body: some View {
        
        content()
            .safeAreaInset(edge: .top, spacing: 0, content: header)
            .safeAreaInset(edge: .bottom, spacing: 0, content: footer)
    }
}

// MARK: - Previews

struct InsetContainerView_Demo: View {
    
    @State private var isScrolling = false
    
    let subtitle: String?
    
    var body: some View {
        
        InsetContainerView {
            
            OffsetReportingScrollView { offset in
                
                VStack(spacing: 0) {
                    
                    Color.blue.opacity(0.2).height(600)
                        .overlay { Text("offset: \(offset)") }
                    
                    Color.green.height(600)
                }
                .onChange(of: offset) { isScrolling = abs($0) > 0.1 }
//                .border(.pink)
            }
//            .border(.black)
            .ignoresSafeArea()
            
        } header: {
            
            HeaderView(
                title: isScrolling ? "Credit Card" : "",
                subtitle: isScrolling ? subtitle : nil,
                action: { print("back button tapped") },
                config: .preview
            )
            .background(Material.ultraThin.opacity(isScrolling ? 1 : 0))
            .background(.orange.opacity(isScrolling ? 0 : 0.5))
            
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
