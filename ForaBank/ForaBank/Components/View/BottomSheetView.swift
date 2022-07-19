//
//  BottomSheetView.swift
//  SwiftUiTest
//
//  Created by Max Gribov on 18.07.2022.
//

import SwiftUI
import Combine

// MARK: - View

extension View {

    func bottomSheet<Content>(isPresented: Binding<Bool>, keyboardOfssetMultiplier: CGFloat = 0.6, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {

        modifier(BottomSheetModifier(isPresented: isPresented, keyboardOfssetMultiplier: keyboardOfssetMultiplier, sheetContent: content))
    }
    
    func bottomSheet<Item, Content>(item: Binding<Item?>, keyboardOfssetMultiplier: CGFloat = 0.6, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item : Identifiable, Content : View {

        let isShowBottomSheet = Binding {
            item.wrappedValue != nil
        } set: { value in
            if value == false {
                item.wrappedValue = nil
            }
        }

        return bottomSheet(isPresented: isShowBottomSheet, keyboardOfssetMultiplier: keyboardOfssetMultiplier) {

            if let unwrapedItem = item.wrappedValue {
                
                content(unwrapedItem)
            }
        }
    }
}

//MARK: - Bottom Sheet Modifier

struct BottomSheetModifier<SheetContent: View>: ViewModifier {

    let isPresented: Binding<Bool>
    let keyboardOfssetMultiplier: CGFloat
    let sheetContent: () -> SheetContent

    @ViewBuilder
    func body(content: Content) -> some View {
 
        if #available(iOS 14.0, *) {
            
            content
                .fullScreenCover(isPresented: isPresented) {
                    BottomSheetView(isPresented: isPresented, keyboardOfssetMultiplier: keyboardOfssetMultiplier, content: sheetContent)
                }
                .transaction({ transaction in
                    transaction.disablesAnimations = true
                })
            
         } else {
             
             content.sheet(isPresented: isPresented, content: sheetContent)
         }
    }
}

//MARK: - Bottom Sheet View

@available(iOS 14.0, *)
struct BottomSheetView<Content: View>: View {
    
    @Binding var isPresented: Bool
    let keyboardOfssetMultiplier: CGFloat
    let content: Content

    @State private var isShutterPresented = false
    @State private var dimmProgress: CGFloat = 0
    @State private var contentSize: CGSize = .zero
    @State private var bottomPadding: CGFloat = 0
    @GestureState private var translation: CGFloat = 0
    @ObservedObject private var keyboardPublisher = KeyboardPublisher.shared

    init(isPresented: Binding<Bool>, keyboardOfssetMultiplier: CGFloat, @ViewBuilder content: () -> Content) {
        
        self._isPresented = isPresented
        self.keyboardOfssetMultiplier = keyboardOfssetMultiplier
        self.content = content()
    }

    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            DimmView(isShutterPresented: $isShutterPresented, progress: $dimmProgress)
                .zIndex(0)
            
            if isShutterPresented {
                
                VStack(spacing: 0) {
                    
                    BottomSheetShutterView(isShutterPresented: $isShutterPresented, content: content)
                    
                    Color.white
                        .frame(width: UIScreen.main.bounds.width, height: max(keyboardPublisher.keyboardHeight * keyboardOfssetMultiplier, 0))
                        
                }
                .zIndex(1)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: BottomSheetPreferenceKey.self, value: proxy.size)
                    }
                )
                .onPreferenceChange(BottomSheetPreferenceKey.self, perform: { self.contentSize = $0 })
                .transition(.move(edge: .bottom))
                .animation(.interactiveSpring().speed(0.5))
                .offset(y: max(translation, 0))
                .gesture(
                    DragGesture().updating(self.$translation) { value, state, _ in
                        state = value.translation.height
                        
                    }.onEnded { value in
                        
                        if value.translation.height > contentSize.height / 3 {
                            
                            isShutterPresented = false
                        }
                    }
                )
                
            } else {
                
                Color.clear
            }
        }
        .background(ClearBackgroundView())
        .ignoresSafeArea(.all, edges: .bottom)
        .ignoresSafeArea(.keyboard)
        .onAppear{
            withAnimation(.interactiveSpring().speed(0.5)) {
                isShutterPresented = true
                dimmProgress = 1.0
            }
        }
        .onChange(of: translation, perform: { newValue in
            
            guard contentSize.height > 0, newValue > 0 else {
                return
            }
            
            dimmProgress = 1 - max(newValue, 0) / contentSize.height
            UIApplication.shared.endEditing()
        })
        .onChange(of: isShutterPresented) { newValue in
            
            if newValue == false {
                
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

@available(iOS 14.0, *)
extension BottomSheetView {
    
    struct DimmView: View {
        
        @Binding var isShutterPresented: Bool
        @Binding var progress: CGFloat
        
        var body: some View {
            
            Color.black
                .opacity(0.3 * progress)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isShutterPresented = false
                }
        }
    }

    struct ClearBackgroundView: UIViewRepresentable {
        
        func makeUIView(context: Context) -> UIView {
            
            let view = UIView()
            DispatchQueue.main.async {
                view.superview?.superview?.backgroundColor = .clear
            }
            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {}
    }
}

//MARK: - Shutter View

struct BottomSheetShutterView<Content: View>: View {
    
    @Binding var isShutterPresented: Bool
    let content: Content

    var body: some View {
        
        content
            .padding(.top, 29)
            .padding(.bottom, 40)
            .frame(width: UIScreen.main.bounds.width)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
            .overlay(IndicatorView(isShutterPresented: $isShutterPresented).offset(x: 0, y: -14))
    }
}

extension BottomSheetShutterView {
    
    struct IndicatorView: View {
        
        @Binding var isShutterPresented: Bool
        
        var body: some View {
            
            VStack {
                
                ZStack {
                    
                    Color.init(white: 1.0, opacity: 0.01)
                    
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 48, height: 5)
                }
                .frame(width: UIScreen.main.bounds.width, height: 44)
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.3)) {
                        isShutterPresented = false
                    }
                }
                
                Spacer()
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
            
            if #available(iOS 14.0, *) {
                BottomSheetView(isPresented: .constant(true), keyboardOfssetMultiplier: 0.5) {
                    Rectangle().fill(Color.red)
                        .frame(height: 500)
                }
            }
            
            ZStack(alignment: .bottom) {
                Color.gray
                    .edgesIgnoringSafeArea(.all)
                BottomSheetShutterView(isShutterPresented: .constant(true), content: Text("Hello, World").frame(height: 300))
            }
        }
    }
}

