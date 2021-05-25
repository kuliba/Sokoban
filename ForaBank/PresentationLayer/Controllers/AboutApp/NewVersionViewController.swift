//
//  NewVersionViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 08.07.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class NewVersionViewController: UIViewController {
   
    

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var errorButton: ButtonRounded!
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationBar.title
        descriptionLabel.text = "Добавлены прелоадеры на экраны: Авторизация, проверка кода, переводы по свободным реквизитам \nДобавлена кнопка назад для экрана - Ввод кода \nИсправлена ошибка с историей операций и графиком платежей на экранах - Вклады, Кредиты \nДобавлен экран загрузки приложения \nДобавлены кнопки 'Купить с applePay', 'Настроить applePay' - кнопки добавлены в тестовом режиме для подключения системы applePay для карт банка \nДобавлены экраны 'Перевод по СБП' \nДобавлен 'Выбор банка получателя' при переводе по системе СБП \nДобавлен экран 'Подтвердите реквизиты' для переводов по системе СБП \nДобавлен экран 'Успешного перевода СБП' \n*Важно, что сейчас переводы по системе СБП идут в шаблонной режиме(На заглушках) \nДобавлен пунк меню 'По номеру телефона(CБП)'"
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
