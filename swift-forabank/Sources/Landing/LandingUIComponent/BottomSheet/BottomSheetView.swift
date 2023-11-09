//
//  BottomSheetView.swift
//
//  Created by Max Gribov on 18.07.2022.
//

import SwiftUI
import Combine

// MARK: - View Extensions

extension View {
    
    func bottomSheet<Item, Content>(
        item: Binding<Item?>,
        animationSpeed: Double = 0.5,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View
    where Item: Identifiable,
          Content: View {
              
              modifier(
                BottomSheetItemModifier(
                    item: item,
                    animationSpeed: animationSpeed,
                    sheetContent: content
                ))
          }
}

//MARK: - Bottom Sheet View

struct BottomSheetView<Content: View>: View {
    
    @Binding var isPresented: Bool
    
    let animationSpeed: Double
    let content: Content
    
    @State private var isShutterPresented = false
    @State private var dimmProgress: CGFloat = 0
    @State private var contentSize: CGSize = .zero
    @State private var bottomPadding: CGFloat = 0
    @GestureState private var translation: CGFloat = 0
    
    init(
        isPresented: Binding<Bool>,
        animationSpeed: Double,
        content: Content
    ) {
        self._isPresented = isPresented
        self.animationSpeed = animationSpeed
        self.content = content
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            DimmView(isShutterPresented: $isShutterPresented, progress: $dimmProgress)
                .zIndex(0)
            
            if isShutterPresented {
                
                BottomSheetShutterView(isShutterPresented: $isShutterPresented, content: content)
                    .zIndex(1)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(key: BottomSheetPreferenceKey.self, value: proxy.size)
                        }
                    )
                    .onPreferenceChange(BottomSheetPreferenceKey.self, perform: { self.contentSize = $0 })
                    .transition(.move(edge: .bottom))
                    .animation(.interactiveSpring().speed(animationSpeed))
                    .offset(y: max(translation, 0))
                    .gesture(
                        DragGesture().updating(self.$translation) { value, state, _ in
                            state = value.translation.height
                            
                        }.onEnded {
                            
                            if $0.translation.height > contentSize.height / 3 {
                                
                                isShutterPresented = false
                            }
                        }
                    )
                
            } else {  Color.clear }
        }
        .background(ClearBackgroundView())
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear{
            withAnimation(.interactiveSpring().speed(0.5)) {
                isShutterPresented = true
                dimmProgress = 1.0
            }
        }
        .onChange(of: translation, perform: {
            
            guard contentSize.height > 0, $0 > 0 else {
                return
            }
            
            dimmProgress = 1 - max($0, 0) / contentSize.height
            UIApplication.shared.endEditing()
        })
        .onChange(of: isShutterPresented) {
            
            if !$0 {
                
                withAnimation(.easeIn(duration: 0.3)) {
                    self.dimmProgress = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                    
                    self.isPresented = false
                }
            }
        }
    }
}

//MARK: - Preference Keys

struct BottomSheetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        _ = nextValue()
    }
}

//MARK: - Previews

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            BottomSheetView(isPresented: .constant(true), animationSpeed: 0.5, content: Rectangle().fill(Color.red)
                .frame(height: 500))
            
            ZStack(alignment: .bottom) {
                Color.gray
                    .ignoresSafeArea(.all, edges: .all)
                BottomSheetShutterView(isShutterPresented: .constant(true), content: Text("Hello, World").frame(height: 300))
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
