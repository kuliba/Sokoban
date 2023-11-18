//
//  OperationView.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI
import PaymentSticker

struct OperationView: View {
    
    @ObservedObject var model: OperationStateViewModel
    
    var body: some View {

        switch model.state {
        case .operation:
            OperationProcessView(model: model)
        
        case let .result(result):
            OperationResultView(
                title: result.title,
                description: result.description,
                amount: result.amount
            ) {
                
                Button("details") {
                    
                    print("details")
                }
            }
        }
    }
}

struct OperationResultView<ButtonsView: View>: View {
    
    let title: String
    let description: String
    let amount: String
    let buttonsView: () -> ButtonsView
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Image(systemName: "photo.artframe")
                .frame(width: 88, height: 88)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            
            Text(amount)
                .font(.largeTitle)
                .foregroundColor(.black)
            
            Spacer()
            
            VStack(spacing: 56) {
             
                buttonsView()
                
                Button {
                    
                    print("button end tapped")
                    
                } label: {
                    
                    Text("На главный")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding(.trailing, 15)
        .padding(.leading, 16)
        .padding(.vertical, 20)
    }
}

struct OperationProcessView: View {
    
    @ObservedObject public var model: OperationStateViewModel
    
    var body: some View {
        
        VStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    
                    ForEach(model.scrollParameters, content: parameterView)
                }
            }
            .padding(.horizontal)
            
            continueButton()
        }
    }
    
    @ViewBuilder
    private func continueButton() -> some View {
        
        if let amount = model.amountParameter {
            
            parameterView(parameter: amount)
            
        } else {
            
            Button {
                model.event(.continueButtonTapped(.continue))
            } label: {
                
                Text("Продолжить")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func parameterView(
        parameter: PaymentSticker.Operation.Parameter
    ) -> some View {
        
        let mapper = ModelToViewModelMapper(model)
        let viewModel = mapper.map(parameter)
        
        ParameterView(
            viewModel: viewModel,
            configuration: .init(
                tipViewConfig: .init(
                    titleFont: .body,
                    titleForeground: .cyan,
                    backgroundView: .gray
                ),
            stickerViewConfig: .init(
                rectangleColor: .gray,
                configHeader: .init(
                    titleFont: .body,
                    titleColor: .cyan,
                    descriptionFont: .body,
                    descriptionColor: .cyan
                ),
                configOption: .init(
                    titleFont: .body,
                    titleColor: .cyan,
                    iconColor: .blue,
                    descriptionFont: .body,
                    descriptionColor: .cyan,
                    optionFont: .body,
                    optionColor: .black
                )),
            selectViewConfig: .init(
                selectOptionConfig: .init(
                    titleFont: .body,
                    titleForeground: .blue,
                    placeholderForeground: .gray,
                    placeholderFont: .body
                ),
                optionsListConfig: .init(
                    titleFont: .body,
                    titleForeground: .cyan
                ),
                optionConfig: .init(
                    nameFont: .body,
                    nameForeground: .cyan
                )),
                productViewConfig: .init(
                    headerTextColor: .accentColor,
                    headerTextFont: .body,
                    textColor: .accentColor,
                    textFont: .body,
                    background: .init(color: .black)
                )
        ))
    }
}

struct OperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        EmptyView()
    }
}
