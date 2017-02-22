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
    func formView(_ formView: FormView, dataForIndex index: Int) -> FormData?
}

/**
 FormView - Manages the stack view containing the FormField's
 */
public final class FormView: UIView {
    
    public weak var formDelegate: FormViewDelegate?
    public weak var formDataSource: FormViewDataSource? {
        didSet {
            reloadForm()
        }
    }
    
    fileprivate let stackView: UIStackView = {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.isBaselineRelativeArrangement = true
        $0.isLayoutMarginsRelativeArrangement = true
        $0.spacing = 10.0
        return $0
    } (UIStackView(arrangedSubviews: []))

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        let scrollView: UIScrollView = {
            $0.isScrollEnabled = true
            return $0
        } (UIScrollView(frame: frame))
        addSubview(scrollView)
        
        stackView.frame = frame
        scrollView.addSubview(stackView)
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
        let count = formDataSource?.numberOfFormFields(self) ?? 0
        for i in 0..<max(count,stackView.arrangedSubviews.count) {
            
            guard let data = formDataSource?.formView(self, dataForIndex: i)
                else { continue }
            
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
        }
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
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.stackView.arrangedSubviews.forEach { $0.isHidden = false }
            }
        }
    }

    public func formField(_ formField: FormField, returnedWith data: FormData) {
        guard let idx = stackView.arrangedSubviews.index(of: formField) else { return }
        formDelegate?.formView(self, fieldAtIndex: idx, returnedWithData: data)
    }
    
}
