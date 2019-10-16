/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

protocol OptionPickerDelegate: class {
    // TODO: Rewrite string to something useful once functional documentation is available
    func setSelectedOption(option: String?)
}

class OptionPickerViewController: UIViewController {
    
    // MARK: - Properties
    var pickerFrame: CGRect!
    var pickerOptions: [String]!
    
    weak var delegate: OptionPickerDelegate!
    
    private lazy var pickerPopupView: UIView = {
        let v = UIView()
        
        // frame
        v.frame = pickerFrame
        v.frame.size.height = pickerFrame.height * CGFloat(pickerOptions.count)
        v.frame.origin.x = pickerFrame.minX - 6
        v.frame.size.width = pickerFrame.width + 6
        
        // appearance
        v.backgroundColor = .white
        
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
        addPickerOptions()
    }
}

private extension OptionPickerViewController {
    func addPickerOptions() {
        for (i, o) in pickerOptions.enumerated() {
            let b = UIButton()
            b.frame = pickerFrame
            b.frame.origin.x = 6
            b.frame.origin.y = pickerFrame.height * CGFloat(i)
            
            b.setTitleColor(.black, for: [])
            b.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
            b.contentHorizontalAlignment = .left
            b.setTitle(o, for: [])
            b.tag = i
            
            b.addTarget(self, action: #selector(dismissLayerClicked), for: .touchUpInside)
            
            pickerPopupView.addSubview(b)
        }
    }
    
    @objc func dismissLayerClicked(sender: UIButton) {
        // If tag == -1 then it's dismissed withoud any option selected
        if sender.tag != -1 {
            delegate?.setSelectedOption(option: pickerOptions[sender.tag])
        }
        dismiss(animated: true, completion: nil)
    }
}
