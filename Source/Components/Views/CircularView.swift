//
//  CircularView.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 02.04.2022.
//

import UIKit

final class CircularView: UIView {
    // MARK: Properties
    
    private let defaultAvatar = UIImage()
    
    // MARK: UI
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    var image: UIImage? { didSet { imageView.image = image } }
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    override func draw(_ rect: CGRect) {
        drawRingFittingInsideSquareView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.height / .multiplier
        clipsToBounds = true
        
        drawRingFittingInsideSquareView()
        shapeLayer.removeFromSuperlayer()
        
        imageView.layer.cornerRadius = imageView.frame.size.height / .multiplier
        imageView.clipsToBounds = true
    }
    
    // MARK: Private
    
    private func setupView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.bottom.trailing.top.equalToSuperview().inset(Constants.padding)
        }

        imageView.image = defaultAvatar
    }
    
    private func drawRingFittingInsideSquareView() {
        let centerPoint = bounds.size.width / .multiplier
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: centerPoint, y: centerPoint),
            radius: centerPoint - (.lineWidth / .multiplier),
            startAngle: .startAngle,
            endAngle: Double.pi * CGFloat.multiplier,
            clockwise: true
        )
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = .lineWidth
        layer.addSublayer(shapeLayer)
    }
}

// MARK: - Constants

private extension CircularView {
    enum Constants {
        static let padding = 10
    }
}

private extension CGFloat {
    static let multiplier: CGFloat = 2
    
    static let lineWidth: CGFloat = 2
    
    static let startAngle: CGFloat = 0
}
