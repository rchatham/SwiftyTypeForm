//
//  FormField.swift
//  HermesTranslator
//
//  Created by Reid Chatham on 1/18/17.
//  Copyright © 2017 Hermes Messenger LLC. All rights reserved.
//

import UIKit
import PhoneNumberKit


public protocol FormFieldDelegate: class {
    func formField(_ formField: FormField, returnedWith data: FormData)
    func formFieldDidEndEditing(_ formField: FormField)
    func formFieldCancelled(_ formField: FormField)
    func formFieldWasSelected(_ formField: FormField)
}

public protocol FormFieldDataSource: class {}


public final class FormField: UIView, UITextFieldDelegate, FormType {
    
    public var configuration: FormFieldConfiguration = FormFieldConfiguration() {
        didSet {
            configurationUpdated()
        }
    }
    
    private(set) public var dataType: FormDataType = .text
    
    public weak var dataSource: FormFieldDataSource?
    public weak var delegate: FormFieldDelegate?
    
    fileprivate let stackView = UIStackView(arrangedSubviews: [])
    
    public var titleLabel: UILabel!
    public var inputField: UIView!
    
    public init(dataType: FormDataType, frame: CGRect = .zero) {
        self.dataType = dataType
        super.init(frame: frame)
        addSubview(stackView)
            
        addConstraints([
            NSLayoutConstraint(item: self, attribute: .leadingMargin,
                               relatedBy: .greaterThanOrEqual,
                               toItem: stackView, attribute: .leading,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .topMargin,
                               relatedBy: .greaterThanOrEqual,
                               toItem: stackView, attribute: .top,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .trailingMargin,
                               relatedBy: .greaterThanOrEqual,
                               toItem: stackView, attribute: .trailing,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .bottomMargin,
                               relatedBy: .greaterThanOrEqual,
                               toItem: stackView, attribute: .bottom,
                               multiplier: 1.0, constant: 0.0)
        ])
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc internal func tap(_ sender: UITapGestureRecognizer) {
        resignFirstResponder()
        delegate?.formFieldCancelled(self)
    }
    
    @discardableResult
    override public func becomeFirstResponder() -> Bool {
        return inputField?.becomeFirstResponder() ?? false
    }
    
    @discardableResult
    override public func resignFirstResponder() -> Bool {
        return inputField?.resignFirstResponder() ?? false
    }
    
    public func getInput() -> FormData {
        
        var data = FormData(type: dataType, data: nil)
        
        switch dataType {
        case .text:
            data.data = (inputField as? UITextField)?.text
        case .image(_):
            data.data = (inputField as? UIImageView)?.image
        case .phone:
            guard
                let rawNumber = (inputField as? PhoneNumberTextField)?.text,
                let currentRegion = (inputField as? PhoneNumberTextField)?.currentRegion
                else { return data }
            data.data = try? PhoneNumberKit().parse(rawNumber, withRegion: currentRegion)
        }
        
        return data
    }
    
    public func configure(for data: FormData) {
        if inputField != nil {
            stackView.removeArrangedSubview(inputField)
            inputField.removeFromSuperview()
        }
        
        switch data.type {
        case .text, .phone:
            let textField = UITextField()
            textField.delegate = self
            textField.enablesReturnKeyAutomatically = true
            textField.returnKeyType = .done
            textField.inputAccessoryView = {
                let button = UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: self,
                    action: #selector(FormField.returnInput(_:))
                )
                $0.setItems([button], animated: false)
                $0.sizeToFit()
                return $0
            } (UIToolbar())
            
            inputField = textField
            
        case .image(_):
            let imageView = UIImageView()
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FormField.pickPhoto(_:)))
            imageView.addGestureRecognizer(tapGesture)
            
            inputField = imageView
            
        }
        dataType = data.type
        
        stackView.addArrangedSubview(inputField)
    }
    
    @discardableResult
    @objc internal func returnInput(_ sender: Any) -> Bool {
        let input = getInput()
        delegate?.formField(self, returnedWith: input)
        resignFirstResponder()
        return true
    }
    
    @objc internal func pickPhoto(_ sender: UITapGestureRecognizer) {
        if case .image(let request) = dataType {
            request() { [weak self] image in
                guard let image = image else { return }
                (self?.inputField as? UIImageView)?.image = image
                self?.returnInput(sender)
            }
        }
    }
    
    private func setup() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(FormField.tap(_:))
        )
        addGestureRecognizer(tap)
        configurationUpdated()
    }
    
    private func configurationUpdated() {
        backgroundColor = configuration.backgroundColor
        alpha = configuration.alpha
        
        _ = {
            $0.axis = configuration.axis
            $0.alignment = configuration.alignment
            $0.distribution = configuration.distribution
            $0.isBaselineRelativeArrangement = configuration.isBaselineRelativeArrangement
            $0.isLayoutMarginsRelativeArrangement = configuration.isLayoutMarginsRelativeArrangement
            $0.spacing = configuration.spacing
        } (stackView)
    }

    // MARK: - UITextFieldDelegate
    
    @objc public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return returnInput(textField)
    }
    
    @objc public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.formFieldWasSelected(self)
    }
    
    @objc public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.formFieldDidEndEditing(self)
    }
}

