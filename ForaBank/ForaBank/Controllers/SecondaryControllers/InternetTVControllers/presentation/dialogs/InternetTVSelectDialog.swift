
import UIKit

class InternetTVSelectDialog: UIView {

    var closeButton: UIButton {
        let button = UIButton()
        button.setTitle("Закрыть", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.black, for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        return button
    }
    var infoImage: UIImageView {
        let imageName = "alert-circle"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 88.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 88.0).isActive = true
        return imageView
    }
    let label = UILabel()
    let radioButton = RadioButton()
//    var button1: CheckBox {
//        let button = CheckBox()
//        button.setTitle("Закрыть1", for: .normal)
//        button.backgroundColor = .clear
//        button.setTitleColor(UIColor.black, for: .normal)
//        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
//        return button
//    }

//    var button2: CheckBox {
//        let button = CheckBox()
//        button.setTitle("Закрыть2", for: .normal)
//        button.backgroundColor = .clear
//        button.setTitleColor(UIColor.black, for: .normal)
//        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
//        return button
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 150.0).isActive = true

        //radioButton.alternateButton = [button1, button2]

        let stackView = UIStackView()
        stackView.axis          = .vertical
        stackView.distribution  = .fillProportionally
        stackView.alignment     = .fill
        stackView.spacing       = 5

        stackView.addArrangedSubview(closeButton)
        stackView.addArrangedSubview(infoImage)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(radioButton)
        //stackView.addArrangedSubview(button1)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true

        //button1.becomeFirstResponder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class RadioButton: UIButton {
    var alternateButton:Array<RadioButton>?

    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
    }

    func unselectAlternateButtons() {
        if alternateButton != nil {
            self.isSelected = true

            for aButton:RadioButton in alternateButton! {
                aButton.isSelected = false
            }
        } else {
            toggleButton()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, with: event)
    }

    func toggleButton() {
        self.isSelected = !isSelected
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = UIColor.turquoise.cgColor
            } else {
                layer.borderColor = UIColor.gray.cgColor
            }
        }
    }
}

class CheckBox: UIView {
    let kContentXibName = "CheckBoxView"

    @IBOutlet weak var button: UIButton!
    
    
    let checkedImage = UIImage(named: "ic_check_circle")! as UIImage
    let uncheckedImage = UIImage(named: "ic_uncheck_circle")! as UIImage

    
    @IBAction func btnAction(_ sender: Any) {
        isChecked = !isChecked
        print("btn5555!!!!")
    }
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                button.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                button.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }

    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        //contentView.fixInView(self)
        anchor(height: 64)
        //hideAll(true)
    }

//    override func awakeFromNib() {
//        addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
//        isChecked = false
//    }

//    @objc func buttonClicked(sender: UIButton) {
//        if sender == self {
//            isChecked = !isChecked
//        }
//    }
}

class SelectVC : AddHeaderImageViewController {

    var spinnerValues = [String : String]()
    var elementID = "-1"
    var spinnerValuesIndexed = [Int: [String : String]]()
    let labelOne: UILabel = {
        let label = UILabel()
        label.text = " "
        //label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let labelTwo: UILabel = {
        let label = UILabel()
        label.text = " "
        //label.backgroundColor = .green
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = .cyan
        return v
    }()
    var titleLabel = UILabel(text: "Выберите значение", font: .boldSystemFont(ofSize: 18), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))

    //var stackView = UIStackView(arrangedSubviews: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        addHeaderImage()
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.backgroundColor = .white
        //view.anchor(width: UIScreen.main.bounds.width, height: 490)

//        stackView = UIStackView(arrangedSubviews: [])
//        stackView.axis = .vertical
//        stackView.alignment = .fill
//        stackView.distribution = .fillProportionally
//        stackView.spacing = 5
//        stackView.isUserInteractionEnabled = false

//        var button1: CheckBox {
//            let button = CheckBox()
//            button.setTitle("Закрыть1", for: .normal)
//            button.backgroundColor = .clear
//            button.setTitleColor(UIColor.black, for: .normal)
//            button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
//            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
//            return button
//        }


        let a = UIScreen.main.bounds.size.width

        view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0).isActive = true

        var index = 0
        spinnerValues.forEach{ key, value in
            let myButton = UIButton(frame: CGRect(x: 30, y: CGFloat(index) * 50.0, width: a - 56, height: 30))
            //myButton.backgroundColor = .gray
            myButton.setTitle("\(value)", for: .normal)
            myButton.setTitleColor(UIColor(hexString: "000000"), for: .normal)
            myButton.addTarget(self, action: #selector(myButtonAction), for: .touchUpInside)
            myButton.tag = index
            scrollView.addSubview(myButton)

            spinnerValuesIndexed[index] = [key: value]
            index += 1
        }


//        for index in 1...10 {
//            let myButton = UIButton(frame: CGRect(x: 30, y: CGFloat(index) * 50.0, width: a - 56, height: 30))
//            //myButton.backgroundColor = .gray
//            myButton.setTitle("Hello UIButton \(index)", for: .normal)
//            myButton.setTitleColor(UIColor(hexString: "000000"), for: .normal)
//            myButton.addTarget(self, action: #selector(myButtonAction), for: .touchUpInside)
//            myButton.tag = index
//            scrollView.addSubview(myButton)
//        }

        scrollView.addSubview(labelOne)
        labelOne.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.0).isActive = true
        labelOne.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16.0).isActive = true

        scrollView.addSubview(labelTwo)
        labelTwo.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10.0).isActive = true
        labelTwo.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: (CGFloat(spinnerValues.count) * 50.0) + 100).isActive = true
        labelTwo.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16.0).isActive = true
        labelTwo.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16.0).isActive = true

        setupConstraint()
    }

    @objc func myButtonAction(sender: UIButton!) {
        print("My Button tapped \(sender.tag)")
        InternetTVInputCell.spinnerValuesSelected[elementID] = spinnerValuesIndexed[sender.tag]
        InternetTVInputCell.iMsg?.handleMsg(what: InternetTVDetailsFormController.msgUpdateTable)
        dismiss(animated: true)
    }

    private func setupConstraint() {
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor,
                paddingTop: 28, paddingLeft: 20)

//        let saveAreaView = UIView()
//        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
//        view.addSubview(saveAreaView)
//        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
//                bottom: view.bottomAnchor, right: view.rightAnchor)

        //stackView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
        //        right: view.rightAnchor, paddingTop: 16)
    }
}
