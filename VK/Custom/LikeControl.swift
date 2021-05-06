//
//  LikeControl.swift
//  VK
//
//  Created by Ilyas Tyumenev on 29/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

@IBDesignable class LikeControl: UIView {    
    @IBInspectable var isLiked: Bool = false {
        didSet {
            updateLike()
        }
    }
    
    @IBInspectable var likesCount: Int = 0 {
        didSet {
            countLabel.text = "\(likesCount)"
        }
    }
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemBlue
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemBlue
        label.text = "\(0)"
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }    
    
    private func setup() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        ])
        
        stackView.addArrangedSubview(likeButton)
        stackView.addArrangedSubview(countLabel)
    }
    
    // MARK: - Actions    
    @objc func likeButtonTapped(_ sender: UIButton) {
        isLiked.toggle()
    }
    
    private func updateLike() {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeButton.tintColor = isLiked ? UIColor.systemRed : UIColor.systemBlue
        countLabel.textColor = isLiked ? UIColor.systemRed : UIColor.systemBlue
        likesCount = isLiked ? likesCount + 1: likesCount - 1
        
        UIView.transition(
            with: countLabel,
            duration: 0.5,
            options: .transitionFlipFromTop,
            animations: { self.countLabel.text = "\(self.likesCount)" }
        )
    }
}
