//
//  PushHistoryCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import UIKit

final class PushHistoryCell: UITableViewCell {
    
    @IBOutlet weak var pushImage: UIImageView!
    @IBOutlet weak var pushTitle: UILabel!
    @IBOutlet weak var pushSubTitle: UILabel!
    @IBOutlet weak var pushTimeLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(_ model: PushHistoryModel.PushHistoryItems) {
        pushTitle.text = model.title
        pushSubTitle.text = model.text ?? ""
        pushTimeLable.text = dateFormater(model.date ?? "", "HH:mm")
    }
    func dateFormater(_ string: String, _ formatter: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let date = dateFormatter.date(from: string)!
        
        let d = DateFormatter()
        d.locale = Locale(identifier: "ru_RU")
        d.dateFormat = formatter

        let stringDate = d.string(from: date)
        return stringDate
    }
    //dd MMMM, E
    //"27.09.2021 12:09:26"
}
