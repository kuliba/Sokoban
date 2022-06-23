//
//  DocumentDelailCellViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 28.05.2022.
//

import SwiftUI


extension DocumentDelailCellView {
    
    class ViewModel: ObservableObject, Identifiable {
        
        let id: UUID
        let title: String
        let content: String?
        
        internal init(id: UUID = UUID(), title: String, content: String? = nil) {
            
            self.id = id
            self.content = content
            self.title = title
        }
        
    }
}

//MARK: - View

struct DocumentDelailCellView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(spacing: 4) {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(verbatim: viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                        .multilineTextAlignment(.leading)
                        .frame(height: 12)
                    
                    if let content = viewModel.content {
                        
                        Text(verbatim: content)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                            .frame(height: 24)
                    }
                }
                
                Spacer()
            }
            
            Divider()
                .foregroundColor(.bordersDivaiderDisabled)
                .frame(height: 1)
        }
        .frame(height: 56)
        
    }
}

//MARK: - Preview

struct DocumentDelailCellView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            DocumentDelailCellView(viewModel: .fio)
                .previewLayout(.fixed(width: 336, height: 60))
            DocumentDelailCellView(viewModel: .regNumber)
                .previewLayout(.fixed(width: 336, height: 60))
            DocumentDelailCellView(viewModel: .dateOfIssue)
                .previewLayout(.fixed(width: 336, height: 60))
            DocumentDelailCellView(viewModel: .codeDepartment)
                .previewLayout(.fixed(width: 336, height: 60))
            DocumentDelailCellView(viewModel: .birthPlace)
                .previewLayout(.fixed(width: 336, height: 60))
            DocumentDelailCellView(viewModel: .birthDay)
                .previewLayout(.fixed(width: 336, height: 60))
        }
    }
}

//MARK: - Preview Content

extension DocumentDelailCellView.ViewModel {
    
    static let fio = DocumentDelailCellView.ViewModel(
        title: "ФИО", content: "Фурсенко Александр Владимирович")
    
    static let regNumber = DocumentDelailCellView.ViewModel(
        title: "Серия и номер", content: "38 06 675475")
    
    static let dateOfIssue = DocumentDelailCellView.ViewModel(
        title: "Дата выдачи", content: "31.09.2009")
    
    static let codeDepartment = DocumentDelailCellView.ViewModel(
        title: "Код подразделения", content: "443-876")
    
    static let birthPlace = DocumentDelailCellView.ViewModel(
        title: "Место рождения", content: "г. Москва")
    
    static let birthDay = DocumentDelailCellView.ViewModel(
        title: "Дата рождения", content: "18.03.1998")
    
    static let exampleArr: [DocumentDelailCellView.ViewModel] = [
        .fio, .regNumber, .dateOfIssue, .codeDepartment, .birthPlace, .birthDay
    ]
}
