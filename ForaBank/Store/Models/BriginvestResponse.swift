/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation

struct BriginvestResponse<T:Decodable>: Decodable {
    
    var result: String?
    var errorMessage: String?
    var data: T?
    
}
