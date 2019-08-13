/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

protocol RemittancePickerDelegate: class {
    func setUpOption(withView view: RemittanceOptionView, atIndex index: Int)
    // TODO: Rewrite string to something useful once functional documentation is available
    func didSelectOptionView(option: RemittanceOptionView?)
}

class RemittancePickerViewController: UIViewController {

    // MARK: - Properties
    var pickerFrame: CGRect!
    var pickerOptions: [RemittanceOptionViewType]!
    var optionViews: [RemittanceOptionView]!
    
    weak var delegate: RemittancePickerDelegate!
    
    private lazy var pickerPopupView: UIView = {
        let v = UIView()
        
        // frame
        v.frame = pickerFrame
        v.frame.size.height = (pickerFrame.height + 11) * CGFloat(pickerOptions.count) - 1
        v.frame.origin.x = pickerFrame.minX //- 6
        v.frame.origin.y = pickerFrame.minY - 5 //- 6
        v.frame.size.width = pickerFrame.width //+ 6
        
        // appearance
        v.backgroundColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 1)
        
        // shadow
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.5
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowRadius = 10
        v.layer.shadowPath = UIBezierPath(rect: v.bounds).cgPath
        
        
        return v
    }()
    
    private lazy var dismissLayerButton: UIButton = {
        let b = UIButton()
        b.frame = view.frame
        b.tag = -1
        b.addTarget(self, action: #selector(dismissLayerClicked), for: .touchUpInside)
        return b
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(dismissLayerButton)
        view.addSubview(pickerPopupView)
        optionViews = [RemittanceOptionView]()
        addPickerOptions()
    }
}

private extension RemittancePickerViewController {
    func addPickerOptions() {
        for (i, o) in pickerOptions.enumerated() {
            let b = UIButton(type: .custom)
            b.backgroundColor = .white
            b.frame = pickerFrame
            b.frame.origin.x = 0//6
            b.frame.size.height = pickerFrame.height + 10
            b.frame.origin.y = (pickerFrame.height + 11) * CGFloat(i)

//            b.setTitleColor(.black, for: [])
//            b.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
//            b.contentHorizontalAlignment = .left
////            b.setTitle(o, for: [])
            b.tag = i

            b.addTarget(self, action: #selector(dismissLayerClicked), for: .touchUpInside)

            let v = RemittanceOptionView(withType: o)
            delegate?.setUpOption(withView: v, atIndex: i)
            v.translatesAutoresizingMaskIntoConstraints = false
            v.tag = i
            v.isUserInteractionEnabled = false
            optionViews.append(v)
            b.addSubview(v)
            b.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v]-5-|", options: [], metrics: nil, views: ["v":v]))
            b.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: ["v":v]))
            
            pickerPopupView.addSubview(b)
        }
    }
    
    @objc func dismissLayerClicked(sender: UIButton) {
        // If tag == -1 then it's dismissed withoud any option selected
        if sender.tag != -1 {
            delegate?.didSelectOptionView(option: optionViews[sender.tag])
        }
        dismiss(animated: true, completion: nil)
    }

}
