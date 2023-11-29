//
//  InputView.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import SwiftUI
import Foundation
import TextFieldComponent
import Combine

class CodeObserver: ObservableObject {
    
    @Published private (set) var code: String? = nil

    private var bindings = Set<AnyCancellable>()

    init(onCode: @escaping (String) -> Void) {
        
        $code
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [onCode] in onCode($0) }
            .store(in: &bindings)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("otpCode"), object: nil)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        let otp = notification.userInfo?["otp"] as? String
        self.code = otp
    }
}


// MARK: - View

struct InputView: View {
    
    @StateObject private var regularFieldViewModel: RegularFieldViewModel
    @StateObject private var codeObserver: CodeObserver
    
    private let title: String
    private let commit: (String) -> Void
    private let warning: String?
    private let configuration: InputConfiguration
    private let textFieldConfig: TextFieldView.TextFieldConfig
    
    init(
        code: String?,
        title: String,
        commit: @escaping (String) -> Void,
        warning: String?,
        configuration: InputConfiguration
    ) {
        let regularFieldViewModel: RegularFieldViewModel = .make(
            code: code,
            placeholderText: "Введите код из смс",
            limit: 6
        )
        
        let codeObserver = CodeObserver(onCode: regularFieldViewModel.setText(to:))
        
        self._regularFieldViewModel = .init(
            wrappedValue: regularFieldViewModel
        )
        self._codeObserver = .init(wrappedValue: codeObserver)
        
        self.title = title
        self.commit = commit
        self.warning = warning
        self.configuration = configuration
        self.textFieldConfig = .init(
            font: .systemFont(ofSize: 16),
            textColor: configuration.textFieldColor,
            tintColor: configuration.textFieldTintColor,
            backgroundColor: configuration.textFieldBackgroundColor,
            placeholderColor: configuration.textFieldPlaceholderColor
        )
    }
    
    var body: some View {
        
        let textField = TextFieldView(
            viewModel: regularFieldViewModel,
            textFieldConfig: textFieldConfig
        )
        
        LabeledView(
            title: title,
            configuration: configuration,
            warning: warning,
            makeLabel: { textField }
        )
        .onChange(of: regularFieldViewModel.text ?? "", perform: commit)

    }
}

public struct InputConfiguration {

    let titleFont: Font
    let titleColor: Color
    
    let iconColor: Color
    let iconName: String
    
    let warningFont: Font
    let warningColor: Color
    
    let textFieldFont: Font
    let textFieldColor: Color
    
    let textFieldTintColor: Color
    let textFieldBackgroundColor: Color
    let textFieldPlaceholderColor: Color
    
    public init(
        titleFont: Font,
        titleColor: Color,
        iconColor: Color,
        iconName: String,
        warningFont: Font,
        warningColor: Color,
        textFieldFont: Font,
        textFieldColor: Color,
        textFieldTintColor: Color,
        textFieldBackgroundColor: Color,
        textFieldPlaceholderColor: Color
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.iconColor = iconColor
        self.iconName = iconName
        self.warningFont = warningFont
        self.warningColor = warningColor
        self.textFieldFont = textFieldFont
        self.textFieldColor = textFieldColor
        self.textFieldTintColor = textFieldTintColor
        self.textFieldBackgroundColor = textFieldBackgroundColor
        self.textFieldPlaceholderColor = textFieldPlaceholderColor
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
       
        #warning("add previews")
        // ParameterView()
        EmptyView()
    }
}
