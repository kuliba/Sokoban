//
//  PlainClientInformView.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 04.10.2024.
//

import SwiftUI

@available(iOS 15, *)
public struct PlainClientInformView: View {

    @State private var isShowNavBar = false
    @State private var shouldScroll = true
    private var axes: Axis.Set { return shouldScroll ? .vertical : [] }
    
    private let config: Config
    private let info: Info
    
    public init(config: Config, info: Info) {
        
        self.config = config
        self.info = info
    }
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            if isShowNavBar {
                
                navBarView()
                    .transition(.identity)
            }
            
            ScrollView(axes, showsIndicators: false) {
                
                contentStack()
                    .background(GeometryReader { geometry in
                        Color.clear
                            .preference(key: ContentHeightKey.self, value: geometry.size.height)
                    })
            }
            .coordinateSpace(name: "scroll")
            .zIndex(-1)
            .onPreferenceChange(ContentHeightKey.self) { contentHeight in
                    
                    isShowNavBar = contentHeight > UIScreen.main.bounds.height
                    shouldScroll = contentHeight > UIScreen.main.bounds.height
            }
        }
    }
    
    private func navBarView() -> some View {
        
        ZStack(alignment: .top) {

            config.colors.grayBackground
                .frame(height: config.sizes.navBarHeight)
                .ignoresSafeArea()
            
            grabberView()
            
            navBarTitle(info.navBarTitle())
        }
    }
    
    private func navBarTitle(_ text: String) -> some View {
        
        Text(text)
            .font(.largeTitle)
            .foregroundColor(.black)
            .padding(.horizontal, config.paddings.horizontal)
            .padding(.vertical, config.paddings.vertical)
            .frame(maxWidth: .infinity, maxHeight: config.sizes.navBarMaxWidth, alignment: .leading)
            .background(config.colors.grayBackground)
    }
    
    private func contentStack() -> some View {
        
        VStack(spacing: config.sizes.spacing) {
            
            if !isShowNavBar { grabberView() }
            
            switch info {
            case .single(let singleInfo):
                singleInfoView(singleInfo)
                
            case .multiple(let multipleInfo):
                multipleInfoView(multipleInfo)
            }
        }
    }
    
    private func grabberView() -> some View {
        
        config.colors.grayGrabber
            .frame(
                width: config.sizes.grabberWidth,
                height: config.sizes.grabberHeight,
                alignment: .top
            )
            .cornerRadius(config.sizes.grabberCornerRadius)
            .padding(.top, config.paddings.topGrabber)
            .ignoresSafeArea()
    }

    private func singleInfoView(_ singleInfo: Info.Single) -> some View {
        
        VStack(spacing: config.sizes.spacing) {
            
            iconView(singleInfo.label.image)
            titleView(singleInfo.label.title)
            
            Text(singleInfo.text)
                .font(config.textConfig.textFont)
                .foregroundColor(config.titleConfig.textColor)
                .padding(.horizontal, config.paddings.horizontal)
        }
    }

    private func multipleInfoView(_ multipleInfo: Info.Multiple) -> some View {
        
        VStack(spacing: config.sizes.spacing) {
            
            if !isShowNavBar {
                iconView(multipleInfo.title.image)
                titleView(multipleInfo.title.title)
            }
            
            VStack(alignment: .leading, spacing: config.sizes.spacing) {
                
                ForEach(multipleInfo.items) { item in
                    
                    PlainClientInformRowView(
                        logo: item.image,
                        text: item.title,
                        config: config
                    )
                }
            }
            .padding(.horizontal, config.paddings.horizontal)
            .padding(.vertical, isShowNavBar ? config.sizes.navBarHeight : 0)
        }
    }
    
    private func iconView(_ image: Image) -> some View {
        
        image
            .resizable()
            .frame(width: config.sizes.iconSize, height: config.sizes.iconSize)
            .padding(.top, config.paddings.topImage)
    }
    
    private func titleView(_ text: String) -> some View {
        
        Text(text)
            .font(config.titleConfig.textFont)
            .foregroundColor(config.titleConfig.textColor)
    }

    private func textView(_ text: Binding<AttributedString>) -> some View {
        
        Text(text.wrappedValue)
            .font(config.textConfig.textFont)
            .foregroundColor(config.textConfig.textColor)
    }
    
    private struct ContentHeightKey: PreferenceKey {
        
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

@available(iOS 15, *)
public extension PlainClientInformView {
    
    typealias Config = PlainClientInformConfig
    typealias Info = ClientInformDataState
}

// MARK: - Preview
@available(iOS 15, *)
struct PlainClientInformView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PlainClientInformView(
            config: .default, 
            info: .preview
        )
    }
}
