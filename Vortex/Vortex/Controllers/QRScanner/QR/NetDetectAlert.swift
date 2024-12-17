//
//  NetDetectAlert.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.08.2021.
//

import UIKit

final class  NetDetectAlert: UIView {
    
    let netIconImage = UIImageView()
    let topLable = UILabel()
    let midleLable = UILabel()
    let hiddenButton = UIButton()
    var a: CGFloat = 0
    var b = 0
    init(_ view: UIView) {
        super.init(frame: view.frame)
        self.backgroundColor = UIColor.alertBgColor
        self.alpha = 1.0
        self.add_CornerRadius(5)
        a = view.frame.width
        self.hiddenButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        
        addTopLable()
        addImage()
        addHiddenButton()
    }
    
    private func position(_ a: CGFloat) {
        UIView.animate(withDuration: 1) {
            self.frame = CGRect(x: 8, y: self.b, width: Int(a) - 16, height: 50)
            self.add_ShedowZero(5, 1.0, UIColor.alertSchedowColor, self.bounds)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.add_ShedowZero(5, 0.5, UIColor.alertSchedowColor, self.bounds)
    }
    
    @objc private func tapButton() {
        self.isHidden = true
    }
    
    func hidden() {
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    var offLine = NSLocalizedString("OffLine", comment: "OffLine")
    private func addTopLable() {
        topLable.text = offLine
        topLable.textAlignment = .center
        topLable.numberOfLines = 0
        topLable.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        topLable.textColor = .white
        topLable._addAlertLable(self)
    }
    

    private func addHiddenButton() {
        hiddenButton.backgroundColor = .clear
        hiddenButton._addAlertButton(self)
    }
    
    private func addImage() {
        let image = UIImage(named: "TapIcon")
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        netIconImage.image = tintedImage
        netIconImage.tintColor = .white
        netIconImage.alpha = 1
        netIconImage._addIconImage(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch UIDevice().type {
            case .iPhone5, .iPhone5S, .iPhone5C, .iPhone6, .iPhone6S, .iPhone6SPlus, .iPhone6Plus, .iPhone7, .iPhone7Plus, .iPhone8, .iPhone8Plus, .iPhoneSE,  .iPhoneSE2, .iPhone12Mini:
                let height: CGFloat?
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                if #available(iOS 13.0, *) {
                    height = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                } else {
                    height = UIApplication.shared.statusBarFrame.height
                }
                let bottomInset = height ?? 0
                b = Int(bottomInset)
                self.frame = CGRect(x: Int(a) / 2, y: Int(bottomInset), width: 0, height: 0)
                position(a)
            default:
                let bottomInset = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 10
                b = Int(bottomInset)
                self.frame = CGRect(x: Int(a) / 2, y: Int(bottomInset), width: 0, height: 0)
                position(a)
        }
    }

}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}

extension UIButton {
    func setupButtonRadius() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}

extension UIImageView {
    func roundCorners(cornerRadius: Double) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}

extension UIView {
    
    func roundCorners(_ corners: CACornerMask, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        self.layer.maskedCorners = corners
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
    }
    
}

extension UIView {
    
    func _addTopLable( _ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.1, constant: 0).isActive = true
    }
    
    func _addMidleLable( _ container: UIView!, _ top: UIView) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: top, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.1, constant: 0).isActive = true
    }
    
    func _addCenterView( _ container: UIView!, _ top: UIView) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: top, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.4, constant: 0).isActive = true
    }
    
    
    func _addYesButton( _ container: UIView!, _ top: UIView) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: top, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.1, constant: 0).isActive = true
    }
    
    func _addNoButton( _ container: UIView!, _ top: UIView) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: top, attribute: .bottom, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.1, constant: 0).isActive = true
    }
    
    func _addActivityView( _ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func _addRequestLable( _ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 0.30, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.3, constant: 0).isActive = true
    }
    
    func _addDatabaseLable( _ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 0.7, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.3, constant: 0).isActive = true
    }
    
    func _addTopNetLable( _ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.1, constant: 0).isActive = true
    }
    
    func _addMidleNetLable( _ container: UIView!, _ top: UIView) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: top, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.2, constant: 0).isActive = true
    }
    
    func _addNetIconImage( _ container: UIView!, _ top: UIView) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: top, attribute: .top, multiplier: 0.9, constant: 0).isActive = true
    }
    
    func _addAlertLable( _ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    func _addIconImage( _ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1, constant: -10).isActive = true
    }
    
    func _addAlertButton( _ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    
}

extension UIView {
    
    /// RGB Color
    func add_RGBColor( _ r: Float, _ g: Float, _ b: Float, _ alpha: Float) {
        self.backgroundColor = UIColor(red: CGFloat(r),
                                       green: CGFloat(g),
                                       blue: CGFloat(b),
                                       alpha: CGFloat(alpha))
    }
    /// HEX Color 8
    func add_HEXColor( _ hex: String ) {
        self.backgroundColor = UIColor(hex: hex)
    }
    /// HEX Color 6
    func add_HEXColor_6( _ hex: String ) {
        self.backgroundColor = UIColor(hexString: hex)
    }
    /// Corner Radius
    func add_CornerRadius( _ radius: Int) {
        self.layer.cornerRadius = CGFloat(radius)
    }
    /// Corner Radius - separately
    func add_CornerRadiusSeparately(_ corners: (Bool, Bool, Bool, Bool), radius: CGFloat){
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            /// Левый верхний - layerMinXMinYCorner
            /// Правый верхний - layerMaxXMinYCorner
            /// Левый нижний - layerMinXMaxYCorner
            /// Правый нижний - layerMaxXMaxYCorner
            if #available(iOS 11.0, *) {
                switch corners {
                case (true, false, false, false):
                    self.layer.maskedCorners = [.layerMinXMinYCorner]
                case (true, true, false, false):
                    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                case (true, true, true, false):
                    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                case (true, true, true, true):
                    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                case (false, false, false, true):
                    self.layer.maskedCorners = [.layerMinXMaxYCorner]
                case (false, false, true, true):
                    self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                case (false, true, true, true):
                    self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
                case (false, true, false, false):
                    self.layer.maskedCorners = [.layerMaxXMinYCorner]
                case (false, false, true, false):
                    self.layer.maskedCorners = [.layerMaxXMaxYCorner]
                case (false, true, true, false):
                    self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                case (true, false, false, true):
                    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
                case (false, true, false, true):
                    self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                case (true, false, true, false):
                    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
                case (true, true, false, true):
                    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
                case (true, false, true, true):
                    self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                case (_, _, _, _):
                    self.layer.maskedCorners = []
                }
                
            } else {
                // Fallback on earlier versions
            }
        }
    /// Border
    func add_Border( _ widht: Int, _ color: UIColor) {
        self.layer.borderWidth = CGFloat(widht)
        self.layer.borderColor = color.cgColor
    }
    /// Shedow Zero
    func add_ShedowZero( _ radius: Int, _ opacity: Float, _ color: UIColor, _ size: CGRect) {
        self.layer.shadowPath = UIBezierPath(rect: size).cgPath
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = color.cgColor
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.clipsToBounds = false
        
    }
    ///
    /// Shedow Contact
    func add_ShedowContact( _ radius: Int,
                            _ opacity: Float,
                            _ color: UIColor,
                            _ shadowSize: Float,
                            _ shedowDistance: Float ) {
        
        let size: CGFloat = CGFloat(shadowSize)
        let distance: CGFloat = CGFloat(shedowDistance)
        let rect = CGRect(
            x: -size,
            y: self.frame.height - (size * 0.4) + distance,
            width: self.frame.width + size * 2,
            height: size
        )
        self.layer.shadowPath = UIBezierPath(ovalIn: rect).cgPath
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = color.cgColor
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.clipsToBounds = false
    }
    /// Contact Shadows with Depth
    func add_ShedowContactWithDepth(_ radius: Int,
                                    _ opacity: Float,
                                    _ color: UIColor,
                                    _ scaleWidth: Double,
                                    _ scaleHeight: Double,
                                    _ offsetX: Float) {
        
        let scale = CGSize(width: scaleWidth, height: scaleHeight)
        let offsetX: CGFloat = CGFloat(offsetX)

        let shadowPath = UIBezierPath()
        shadowPath.move(to:
            CGPoint(
                x: 0,
                y: self.frame.height
            )
        )
        shadowPath.addLine(to:
            CGPoint(
                x: self.frame.width,
                y: self.frame.height
            )
        )
        shadowPath.addLine(to:
            CGPoint(
                x: self.frame.width * scale.width + offsetX,
                y: self.frame.height * (1 + scale.height)
            )
        )
        shadowPath.addLine(to:
            CGPoint(
                x: self.frame.width * (1 - scale.width) + offsetX,
                y: self.frame.height * (1 + scale.height)
            )
        )
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = color.cgColor
        
    }
    /// Contact Shadows with Curve
    func add_ShedowContactWithCurve(_ radius: Int,
                                    _ opacity: Float,
                                    _ color: UIColor,
                                    _ shadowWidth: Double,
                                    _ shadowHeight: Double,
                                    _ curve: Float) {

        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint.zero)
        shadowPath.addLine(to: CGPoint(
            x: self.frame.width,
            y: 0
        ))
        shadowPath.addLine(to: CGPoint(
            x: self.frame.width,
            y: self.frame.height + CGFloat(curve)
        ))
        shadowPath.addCurve(
            to: CGPoint(
                x: 0,
                y: self.frame.height + CGFloat(curve)
            ),
            controlPoint1: CGPoint(
                x: self.frame.width,
                y: self.frame.height
            ),
            controlPoint2: CGPoint(
                x: 0,
                y: self.frame.height
            )
        )
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = color.cgColor
        
    }
    
    /// Gradient View
    func add_Gradient( _ startPoint: (Double, Double),_ endPoint: (Double, Double), _ colorArray: [UIColor], _ location: [NSNumber], _ alpha: Float) {
        let gradient = CAGradientLayer()
        let b = colorArray.map{ $0.withAlphaComponent(CGFloat(alpha))}
        let a = b.map{ $0.cgColor}
        gradient.startPoint = CGPoint(x: startPoint.0, y: startPoint.1)
        gradient.endPoint = CGPoint(x: endPoint.0, y: endPoint.1)
        gradient.colors = a
        gradient.locations = location
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    /// Radial Gradient View
    func add_RadialGradient(_ colorArray: [UIColor], _ alpha: Float, _ gradientType: CAGradientLayerType) {
        let gradient = CAGradientLayer()
        gradient.type = gradientType
        let b = colorArray.map{ $0.withAlphaComponent(CGFloat(alpha))}
        let a = b.map{ $0.cgColor}
        gradient.colors = a
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        let endY = 0.5 + self.frame.size.width / self.frame.size.height / 2
       
        gradient.endPoint = CGPoint(x: 1, y: endY)
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
    /// Animate Gradient View
    func add_AnimateGradient(_ startPoint: (Double, Double),_ endPoint: (Double, Double), _ colorArray: [UIColor], _ location: [NSNumber], _ alpha: Float, _ duration: Double, _ repeatCount: Float) {
        let gradient = CAGradientLayer()
        let b = colorArray.map{ $0.withAlphaComponent(CGFloat(alpha))}
        let a = b.map{ $0.cgColor}
        gradient.startPoint = CGPoint(x: startPoint.0, y: startPoint.1)
        gradient.endPoint = CGPoint(x: endPoint.0, y: endPoint.1)
        gradient.colors = a
        gradient.locations = location
        
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.0, 0.0, 0.25]
        gradientAnimation.toValue = [0.75, 1.0, 1.0]
        gradientAnimation.duration = duration
        gradientAnimation.repeatCount = repeatCount
        gradient.add(gradientAnimation, forKey: nil)
        gradient.frame = CGRect(
          x: -bounds.size.width,
          y: bounds.origin.y,
          width: 3 * bounds.size.width,
          height: bounds.size.height)
   //     gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
    
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
    convenience init(hexString: String) {
            let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int = UInt64()
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
            }
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        }
    
    public static var backGroundColor: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return .black
                } else {
                    /// Return the color for Light Mode
                    return .white
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return .white
        }
    }()
    
    public static var alertSchedowColor: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
                } else {
                    /// Return the color for Light Mode
                    return #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
        }
    }()
    
    public static var alertBgColor: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
                } else {
                    /// Return the color for Light Mode
                    return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
    }()
    
}

