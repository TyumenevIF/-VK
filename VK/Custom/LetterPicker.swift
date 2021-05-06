//
//  LetterPicker.swift
//  VK
//
//  Created by Ilyas Tyumenev on 02/07/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

protocol LetterPickerDelegate: class {
    func letterPicked(_ letter: String)
}

final class LetterPicker: UIView {
    weak var delegate: LetterPickerDelegate?
    
    var letters: [String] = "abcdefghijklmnopqrstuvwxyzабвгдеёжзийклмнопрстуфхцчшщъьэюя".map { String($0) } {
        didSet {
            setupButtons()
        }
    }
    
    // MARK: - Views
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    var buttons: [UIButton] = []
    private var lastPressedButton: UIButton?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setupButtons()
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        ])
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        addGestureRecognizer(pan)
    }
    
    private func setupButtons() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons = []
        lastPressedButton = nil
        
        for letter in letters {
            let button = UIButton(type: .system)
            button.setTitle(letter.uppercased(), for: .normal)
            button.addTarget(self, action: #selector(letterTapped), for: .touchDown)
            buttons.append(button)
            stackView.addArrangedSubview(button)
            button.heightAnchor.constraint(equalToConstant: 13.5).isActive = true
        }
    }
    
    // MARK: - letterTapped    
    @objc func letterTapped(_ sender: UIButton) {
        guard lastPressedButton != sender else { return }
        
        lastPressedButton = sender
        let letter = sender.title(for: .normal) ?? ""
        delegate?.letterPicked(letter)
    }
    
    @objc func panAction(_ recognizer: UIPanGestureRecognizer) {
        let anchorPoint = recognizer.location(in: stackView) // отслеживает координату recognizer (здесь - при нажатом пальце пользователя)
        let buttonHeight = stackView.bounds.height / CGFloat(buttons.count) // высота кнопки = высота всего стэка / кол-во элементов
        let buttonIndex = max(0, min(buttons.count - 1, Int(anchorPoint.y / buttonHeight)))
        
        unhighlightButtons()
        
        let button = buttons[buttonIndex]
        button.isHighlighted = true
        letterTapped(button)
        
        if recognizer.state == .ended {
            unhighlightButtons()
        }
    }
    
    private func unhighlightButtons() {
        buttons.forEach { $0.isHighlighted = false }
    }
}
