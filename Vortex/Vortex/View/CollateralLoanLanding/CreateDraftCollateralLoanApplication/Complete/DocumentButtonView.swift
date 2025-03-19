//
//  DocumentButtonView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 14.03.2025.
//

import SwiftUI
import UIPrimitives

struct DocumentButton: View {
    
    @State private var isSheetPresented: Bool = false
    
    @Binding private var state: DocumentButtonState
    
    let getDocument: () -> Void
    let goToPlaces: () -> Void
    let goToMain: () -> Void
    
    init(
        state: Binding<DocumentButtonState>,
        goToPlaces: @escaping () -> Void,
        goToMain: @escaping () -> Void,
        getDocument: @escaping () -> Void
    ) {
        self._state = state
        self.goToPlaces = goToPlaces
        self.goToMain = goToMain
        self.getDocument = getDocument
    }
    
    var body: some View {
        
        circleButton(image: .ic24File, title: "\nДокумент", action: startDownload)
            .sheet(isPresented: $isSheetPresented) {
                
                switch state {
                case let .completed(pdfDocument):
                    PDFDocumentView(document: pdfDocument)
                        .navigationBarWithClose(title: "", dismiss: { isSheetPresented = false })

                case let .failure(failure):
                    switch failure {
                    case let .informer(informerData):
                        
                        InformerView(
                            viewModel: .init(
                                message: informerData.message,
                                icon: informerData.icon.image
                            )
                        )
                        .padding(.top, 30)
                        .padding(.bottom, .infinity)

                    default:
                        Color.white
                            .alert(
                                item: alert,
                                content: makeAlert
                            )
                    }
                    
                default:
                    Color.white
                        .loader(isLoading: true, color: .clear)
                }
            }
    }
    
    private var alert: Alert? {
        
        switch state {
        case let .failure(failure):
            switch failure {
            case .informer:
                return nil
                
            case let .alert(message):
                return .failure(message)
                
            case .offline:
                return .offline
            }
            
        default:
            return nil
        }
    }
    
    enum Alert {
        
        case failure(String)
        case offline
    }
    
    private func startDownload() {
        
        isSheetPresented = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
            
            getDocument()
        }
    }
    
    func circleButton(
        image: Image,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        
        ButtonIconTextView(viewModel: .init(
            icon: .init(image: image, background: .circle),
            title: .init(text: title),
            orientation: .vertical,
            action: action
        ))
        .frame(width: 100, height: 92, alignment: .top)
    }
    
    private func makeAlert(
        alert: Alert
    ) -> SwiftUI.Alert {
        
        switch alert {
            
        case let .failure(failure):
            return .init(
                title: Text("Ошибка"),
                message: Text(failure),
                dismissButton: .default(Text("ОK")) { goToMain() }
            )
            
        case .offline:
            let alertViewModel = SwiftUI.Alert.ViewModel(
                title: "Форма временно недоступна",
                message: "Для получения Заявления-анкеты по вкладу обратитесь в отделение банка",
                primary: .init(type: .cancel, title: "Наши офисы", action: { goToPlaces() }),
                secondary: .init(type: .default, title: "ОК", action: { isSheetPresented = false }))
            
            return .init(with: alertViewModel)
        }
    }
}

extension DocumentButton {
    
    static let preview = DocumentButton(
        state: .constant(.pending),
        goToPlaces: {},
        goToMain: {},
        getDocument: {})
}

extension DocumentButton.Alert: Identifiable {
    
    var id: String {
        
        switch self {
        case let .failure(failure):
            return failure
        case .offline:
            return "offline"
        }
    }
}
