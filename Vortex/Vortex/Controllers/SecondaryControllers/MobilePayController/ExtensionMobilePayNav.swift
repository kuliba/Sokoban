//
//  ExtensionMobilePayNav.swift
//  Vortex
//
//  Created by Константин Савялов on 22.09.2021.
//

import UIKit

extension MobilePayViewController {
    
    func setupNavBar() {
        
        if paymentTemplate != nil {
            let button = UIBarButtonItem(image: UIImage(named: "edit-2"),
                                         landscapeImagePhone: nil,
                                         style: .done,
                                         target: self,
                                         action: #selector(updateNameTemplate))
            button.tintColor = .black
            navigationItem.rightBarButtonItem = button
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_button") , style: .plain, target: self, action: #selector(backAction))
            
        } else {
        
            navigationItem.title = "Оплата мобильной связи"
       
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_button") , style: .plain, target: self, action: #selector(backAction))
            
            self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .normal)
            self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .highlighted)
        }
    }
    
    @objc func backAction() {
        
        viewModel?.closeAction()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func updateNameTemplate() {
        self.showInputDialog(title: "Название шаблона",
                             actionTitle: "Сохранить",
                             cancelTitle: "Отмена",
                             inputText: paymentTemplate?.name,
                             inputPlaceholder: "Введите название шаблона",
                             actionHandler:  { text in
            
            guard let text = text else { return }
            guard let templateId = self.paymentTemplate?.paymentTemplateId else { return }
            
            if text.isEmpty != true {
                if text.count < 20 {
                Model.shared.action.send(ModelAction.PaymentTemplate.Update.Requested(
                    name: text,
                    parameterList: nil,
                    paymentTemplateId: templateId))
                    
                // FIXME: В рефактре нужно слушатель на обновление title
                    self.parent?.title = text

                } else {
                    self.showAlert(with: "Ошибка", and: "В названии шаблона не должно быть более 20 символов")
                }
            } else {
                self.showAlert(with: "Ошибка", and: "Название шаблона не должно быть пустым")
            }
        })
    }
}
