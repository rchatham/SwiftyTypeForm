//
//  ViewController.swift
//  SwiftyTypeFormDemo
//
//  Created by Reid Chatham on 2/21/17.
//  Copyright © 2017 Reid Chatham. All rights reserved.
//

import UIKit
import SwiftyTypeForm

class ViewController: FormViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setup() {
        
        view.backgroundColor = .cyan
        
        dataSource = FormViewControllerDataSource()
        dataSource?.formData = [
            FormData(type: .image(request: { _ in }), data: nil),
            FormData(type: .text, data: "First name..."),
            FormData(type: .text, data: "Last name..."),
            FormData(type: .text, data: "Display name...")
        ]
    }
}

