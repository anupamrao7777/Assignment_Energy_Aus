//
//  ReusableView.swift
//
//


import Foundation
import UIKit

/// Object, that adopts this protocol, will use identifier that matches name of its class.
protocol ReusableView: class {}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UIView: ReusableView {}
