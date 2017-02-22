//
//  FormViewOptions.swift
//  SwiftyTypeForm
//
//  Created by Reid Chatham on 2/22/17.
//  Copyright © 2017 Reid Chatham. All rights reserved.
//

import UIKit

public struct FormViewConfiguration {
    var axis: UILayoutConstraintAxis = .vertical
    var alignment: UIStackViewAlignment = .fill
    var distribution: UIStackViewDistribution = .equalCentering
    var spacing: CGFloat = 10.0
    var isBaselineRelativeArrangement: Bool = false
    var isLayoutMarginsRelativeArrangement: Bool = true
    var alpha: CGFloat = 1.0
    var backgroundColor: UIColor = .white
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}
