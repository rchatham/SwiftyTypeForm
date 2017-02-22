//
//  FormViewController.swift
//  HermesTranslator
//
//  Created by Reid Chatham on 2/19/17.
//  Copyright © 2017 Hermes Messenger LLC. All rights reserved.
//

import UIKit


/**
 FormViewController - Sets up a FormView as the view and holds a reference to it with `formView`. Also sets itself to the delegate and if a dataSource object is specified it automatically udpates its backing data when a FormField updates it's content.
 */
open class FormViewController: UIViewController, FormViewDelegate {
    
    /**
     Holds a reference to the FormView. Sets the FormViewController's view property to the formView when set and sets the formView's formDelegate property to itself.
     */
    public var formView: FormView? {
        didSet {
            formView?.formDelegate = self
            view = formView
        }
    }

    /**
     Optional FormViewControllerDataSource property that sets the FormViewController to its formView property and sets itself to the formView's formDataSource property.
     */
    public var dataSource: FormViewControllerDataSource? {
        didSet {
            dataSource?.formView = formView
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        formView = FormView(frame: view.frame)
    }

    // MARK: - FormViewDelegate
    
    public func formView(_ formView: FormView, fieldAtIndex index: Int, returnedWithData data: FormData) {
        dataSource?.formData[index] = data
    }
}
