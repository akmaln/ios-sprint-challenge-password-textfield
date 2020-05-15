//
//  PasswordField.swift
//  PasswordTextField
//
//  Created by Ben Gohlke on 6/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum PasswordStrength: String {
    case weak = "Too Weak"
    case medium = "Could be stronger"
    case strong = "Strong password"
}


class PasswordField: UIControl {
    
    // Public API - these properties are used to fetch the final password and strength values
    private (set) var password: String = ""
    private (set) var passwordStrength: PasswordStrength = .weak
    private var passwordShouldShow = false
    
    private let standardMargin: CGFloat = 8.0
    private let textFieldContainerHeight: CGFloat = 50.0
    private let textFieldMargin: CGFloat = 6.0
    private let colorViewSize: CGSize = CGSize(width: 60.0, height: 5.0)
    
    private let labelTextColor = UIColor(hue: 233.0/360.0, saturation: 16/100.0, brightness: 41/100.0, alpha: 1)
    private let labelFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    
    private let textFieldBorderColor = UIColor(hue: 208/360.0, saturation: 80/100.0, brightness: 94/100.0, alpha: 1)
    private let bgColor = UIColor(hue: 0, saturation: 0, brightness: 97/100.0, alpha: 1)
    
    // States of the password strength indicators
    private let unusedColor = UIColor(hue: 210/360.0, saturation: 5/100.0, brightness: 86/100.0, alpha: 1)
    private let weakColor = UIColor(hue: 0/360, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let mediumColor = UIColor(hue: 39/360.0, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let strongColor = UIColor(hue: 132/360.0, saturation: 60/100.0, brightness: 75/100.0, alpha: 1)
    
    private var titleLabel: UILabel = UILabel()
    private var textField: UITextField = UITextField()
    private var showHideButton: UIButton = UIButton()
    private var weakView: UIView = UIView()
    private var mediumView: UIView = UIView()
    private var strongView: UIView = UIView()
    private var strengthDescriptionLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textField.delegate = self
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textField.delegate = self
        setup()
    }
    
    func setup() {
        // Lay out your subviews here
        backgroundColor = bgColor
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Enter Password"
        titleLabel.textColor = labelTextColor
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        ])
        
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.layer.borderColor = textFieldBorderColor.cgColor
        textField.layer.cornerRadius = 0
        textField.layer.borderWidth = 1.5
        textField.becomeFirstResponder()
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
        
        addSubview(weakView)
        addSubview(mediumView)
        addSubview(strongView)
        weakView.translatesAutoresizingMaskIntoConstraints = false
        mediumView.translatesAutoresizingMaskIntoConstraints = false
        strongView.translatesAutoresizingMaskIntoConstraints = false
        weakView.backgroundColor = weakColor
        mediumView.backgroundColor = unusedColor
        strongView.backgroundColor = unusedColor
        
        NSLayoutConstraint.activate([
            weakView.heightAnchor.constraint(equalToConstant: colorViewSize.height),
            weakView.widthAnchor.constraint(equalToConstant: colorViewSize.width),
            mediumView.heightAnchor.constraint(equalToConstant: colorViewSize.height),
            mediumView.widthAnchor.constraint(equalToConstant: colorViewSize.width),
            strongView.heightAnchor.constraint(equalToConstant: colorViewSize.height),
            strongView.widthAnchor.constraint(equalToConstant: colorViewSize.width)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [weakView, mediumView, strongView])
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = standardMargin

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 13),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        ])
        
        addSubview(strengthDescriptionLabel)
        strengthDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        strengthDescriptionLabel.text = "Too weak"
        strengthDescriptionLabel.textColor = labelTextColor
        
        NSLayoutConstraint.activate([
            strengthDescriptionLabel.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 6),
            strengthDescriptionLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4)
        ])
        
        addSubview(showHideButton)
        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        showHideButton.setImage(UIImage(named: "eyes-closed"), for: .normal)
        showHideButton.addTarget(self, action: #selector(showHideButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            showHideButton.topAnchor.constraint(equalTo: textField.topAnchor),
            showHideButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -4),
            showHideButton.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
        ])
    }
    
    @objc func showHideButtonTapped(_ : UIButton) {
        textField.isSecureTextEntry.toggle()
        if textField.isSecureTextEntry {
            showHideButton.setImage(UIImage(named: "eyes-closed"), for: .normal)
        } else {
            showHideButton.setImage(UIImage(named: "eyes-open"), for: .normal)
        }
    }
    
    func findPasswordStrength(_ password: String) -> PasswordStrength {
            var strength: PasswordStrength

            switch password.count {
            case 0...8:
                strength = .weak
                weakView.backgroundColor = weakColor
                mediumView.backgroundColor = unusedColor
                strongView.backgroundColor = unusedColor
            case 9...14:
                strength = .medium
                weakView.backgroundColor = weakColor
                mediumView.backgroundColor = mediumColor
                strongView.backgroundColor = unusedColor
            default:
                strength = .strong
                weakView.backgroundColor = weakColor
                mediumView.backgroundColor = mediumColor
                strongView.backgroundColor = strongColor
            }

            strengthDescriptionLabel.text = strength.rawValue

            if passwordStrength != strength {
                flareAnimation(strength)
            }

            return strength
        }

        func flareAnimation(_ level: PasswordStrength) {
            var view: UIView

            switch level {
            case .weak:
                view = weakView
            case .medium:
                view = mediumView
            case .strong:
                view = strongView
            }

            let animationBlock = {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.8) {
                    view.transform = CGAffineTransform(scaleX: 1.0, y: 1.8)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                    view.transform = .identity
                }
            }

            UIView.animateKeyframes(withDuration: 0.5,
                                    delay: 0, options: [],
                                    animations: animationBlock,
                                    completion: nil)
        }
}

extension PasswordField: UITextFieldDelegate {
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        // TODO: send new text to the determine strength method
        passwordStrength = findPasswordStrength(newText)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        password = textField.text ?? ""
        sendActions(for: [.valueChanged])
        textField.resignFirstResponder()
        return true
    }
}
