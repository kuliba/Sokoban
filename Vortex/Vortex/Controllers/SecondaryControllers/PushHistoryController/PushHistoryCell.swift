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
        let pushType = model.type ?? ""
        let title = model.title ?? ""
        
        pushTitle.setAttributedText(primaryString: pushType,
                                    textColor: .black,
                                    font: UIFont(name: "Inter-Medium", size: 16)!,
                                    secondaryString: title,
                                    secondaryTextColor: .black,
                                    secondaryFont: UIFont(name: "Inter-Medium", size: 16)!)
        
        
        pushSubTitle.text = model.text ?? ""
        pushTimeLable.text = dateFormater(model.date ?? "", "HH:mm")
    }
    func dateFormater(_ string: String, _ formatter: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let date = dateFormatter.date(from: string)!
        
        let d = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        d.locale = Locale(identifier: "ru_RU")
        d.dateFormat = formatter

        let stringDate = d.string(from: date)
        return stringDate
    }
    
}

extension UILabel {

    /** Sets up the label with two different kinds of attributes in its attributed text.
     *  @params:
     *  - primaryString: the normal attributed string.
     *  - secondaryString: the bold or highlighted string.
     */

    func setAttributedText(primaryString: String, textColor: UIColor, font: UIFont, secondaryString: String, secondaryTextColor: UIColor, secondaryFont: UIFont) {

        let completeString = "\(primaryString) \(secondaryString)"

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let completeAttributedString = NSMutableAttributedString(
            string: completeString, attributes: [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
        )

        let secondStringAttribute: [NSAttributedString.Key: Any] = [
            .font: secondaryFont,
            .foregroundColor: secondaryTextColor,
            .paragraphStyle: paragraphStyle
        ]

        let range = (completeString as NSString).range(of: secondaryString)

        completeAttributedString.addAttributes(secondStringAttribute, range: range)

        self.attributedText = completeAttributedString
    }
}
