//
//  FormData.swift
//  HermesTranslator
//
//  Created by Reid Chatham on 2/19/17.
//  Copyright © 2017 Hermes Messenger LLC. All rights reserved.
//

import UIKit
import PhoneNumberKit

public enum FormDataType {
    case text
    case image(request: (@escaping (UIImage?)->Void)->Void)
    case phone
}

public struct FormData {
    public let type: FormDataType
    public var data: Any?
    public init(type: FormDataType, data: Any?) {
        self.type = type; self.data = data
    }
}

extension FormData {
    public init(text: String) {
        self.type = .text; self.data = text
    }
    public init(image: UIImage, request: @escaping (@escaping(UIImage?)->Void)->Void) {
        self.type = .image(request: request); self.data = image
    }
    public init(phone: PhoneNumber) {
        self.type = .phone; self.data = phone
    }
}

public protocol FormType {
    var dataType: FormDataType { get }
    weak var inputField: UIView! { get set }
    func getInput() -> FormData
    func configure(for data: FormData)
}




extension FormDataType: Equatable {
    public static func ==(lhs: FormDataType, rhs: FormDataType) -> Bool {
        switch (lhs, rhs) {
        case (.text, .text): return true
        case (.phone, .phone): return true
        case (.image, .image): return true
        default: return false
        }
    }
}

extension FormData: Equatable {
    public static func ==(lhs: FormData, rhs: FormData) -> Bool {
        guard lhs.type == rhs.type else { return false }
        switch (lhs.type, lhs.data, rhs.data) {
        case (.text, let ld, let rd):
            return (ld as? String) == (rd as? String)
        case (.phone, let ld, let rd):
            return (ld as? String) == (rd as? String)
        case (.image, let ld, let rd):
            return (ld as? UIImage) == (rd as? UIImage)
        }
    }
}

