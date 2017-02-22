//
//  FormViewControllerDataSource.swift
//  HermesTranslator
//
//  Created by Reid Chatham on 2/20/17.
//  Copyright © 2017 Hermes Messenger LLC. All rights reserved.
//

import Foundation

/**
 FormViewControllerDataSource holds an array of FormData objects that reloads the form whenever the the data gets updated.
 */
public final class FormViewControllerDataSource: FormViewDataSource {
    
    public var formData: [FormData] = [] {
        didSet {
            formView?.reloadForm()
        }
    }
    
    public weak var formView: FormView? {
        didSet {
            formView?.dataSource = self
        }
    }
    
    public init() {}
    
    public func numberOfFormFields(_ formView: FormView) -> Int {
        return formData.count
    }
    
    public func formView(_ formView: FormView, formDataForIndex index: Int) -> FormData {
        return formData[index]
    }
    
}
