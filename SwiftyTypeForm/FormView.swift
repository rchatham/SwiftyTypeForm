//
//  FormView.swift
//  HermesTranslator
//
//  Created by Reid Chatham on 2/20/17.
//  Copyright © 2017 Hermes Messenger LLC. All rights reserved.
//

import UIKit

public protocol FormViewDelegate: class {
    func formView(_ formView: FormView, fieldAtIndex index: Int, returnedWithData data: FormData)
}

public protocol FormViewDataSource: class {
    func numberOfFormFields(_ formView: FormView) -> Int
    func formView(_ formView: FormView, formDataForIndex index: Int) -> FormData
    func formView(_ formView: FormView, formFieldConfigurationForIndex index: Int) -> FormFieldConfiguration?
}

extension FormViewDataSource {
    public func formView(_ formView: FormView, formFieldConfigurationForIndex index: Int) -> FormFieldConfiguration? { return nil }
}

/**
 FormView - Manages the stack view containing the FormField's
 */
public final class FormView: UIView {
    
    public var configuration: FormViewConfiguration = FormViewConfiguration() {
        didSet {
            configurationUpdated()
        }
    }
    
    public weak var delegate: FormViewDelegate?
    public weak var dataSource: FormViewDataSource? {
        didSet {
            reloadForm()
        }
    }
    
    fileprivate let scrollView: UIScrollView = {
        $0.isScrollEnabled = true
        return $0
    } (UIScrollView())
    
    fileprivate let stackView = UIStackView(arrangedSubviews: [])

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.frame = frame
        addSubview(scrollView)
        
        stackView.center = scrollView.center
        scrollView.addSubview(stackView)
        
        configurationUpdated()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func formField(at index: Int) -> FormField? {
        guard index < stackView.arrangedSubviews.count else { return nil }
        return (stackView.arrangedSubviews[index] as? FormField)
    }
    
    public func formData(at index: Int) -> FormData? {
        return formField(at: index)?.getInput()
    }
    
    public func reloadForm() {
        let count = dataSource?.numberOfFormFields(self) ?? 0
        for i in 0..<max(count,stackView.arrangedSubviews.count) {
            
            guard let data = dataSource?.formView(self, formDataForIndex: i) else { continue }
            
            if i >= stackView.arrangedSubviews.count {
                let field = FormField(dataType: data.type)
                field.configure(for: data)
                field.delegate = self
                stackView.addArrangedSubview(field)
                
            } else if i >= count {
                let field = formField(at: i)!
                stackView.removeArrangedSubview(field)
                field.removeFromSuperview()
                
            } else if let field = formField(at: i), field.getInput() != data {
                field.configure(for: data)
                
            }
            
            if let field = formField(at: i),
                let configuration = dataSource?.formView(self, formFieldConfigurationForIndex: i) {
                field.configuration = configuration
            }
        }
    }
    
    private func configurationUpdated() {
        backgroundColor = configuration.backgroundColor
        alpha = configuration.alpha
        
        _ = {
            $0.contentInset = configuration.contentInset
        } (scrollView)
        
        _ = {
            $0.axis = configuration.axis
            $0.alignment = configuration.alignment
            $0.distribution = configuration.distribution
            $0.spacing = configuration.spacing
            $0.isBaselineRelativeArrangement = configuration.isBaselineRelativeArrangement
            $0.isLayoutMarginsRelativeArrangement = configuration.isLayoutMarginsRelativeArrangement
        } (stackView)
    }

}

extension FormView: FormFieldDataSource {}

extension FormView: FormFieldDelegate {

    public func formFieldWasSelected(_ formField: FormField) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            formField.isHidden = false
            self?.stackView.arrangedSubviews
                .filter { $0 !== formField }
                .forEach { $0.isHidden = true }
        }
    }

    public func formFieldCancelled(_ formField: FormField) {
        guard let idx = stackView.arrangedSubviews.index(of: formField) else { return }
        if let field = self.formField(at: idx+1) {
            field.becomeFirstResponder()
        } else {
            let views = stackView.arrangedSubviews
            
            UIView.animate(withDuration: 0.3) {
                for view in views {
                    view.isHidden = false
                }
            }
        }
    }

    public func formField(_ formField: FormField, returnedWith data: FormData) {
        guard let idx = stackView.arrangedSubviews.index(of: formField) else { return }
        delegate?.formView(self, fieldAtIndex: idx, returnedWithData: data)
    }
    
}
