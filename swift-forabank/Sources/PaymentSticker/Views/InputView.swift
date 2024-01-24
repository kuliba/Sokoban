//
//  InputView.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import SwiftUI
import Foundation
import TextFieldComponent

// MARK: - View

struct InputView: View {
    
    @StateObject private var regularFieldViewModel: RegularFieldViewModel
    private let codeObserver: NotificationObserver<String>
    
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
            keyboardType: .decimal,
            text: code,
            placeholderText: "Введите код из смс",
            limit: 6
        )
        
        let codeObserver = NotificationObserver<String>(
            notificationName: "otpCode",
            userInfoKey: "otp",
            onReceive: regularFieldViewModel.setText(to:)
        )
        
        self._regularFieldViewModel = .init(
            wrappedValue: regularFieldViewModel
        )

        self.codeObserver = codeObserver
        
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

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
       
        #warning("add previews")
        // ParameterView()
        EmptyView()
    }
}
