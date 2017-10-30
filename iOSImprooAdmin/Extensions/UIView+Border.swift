//
//  UIView + Border.swift
//  Improo
//
//  Created by Zakhar Garan on 18.10.17.
//  Copyright © 2017 GaranZZ. All rights reserved.
//

import UIKit

extension UIView {
    func addBorder(width: CGFloat = 2, color: UIColor = UIColor.black) {
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderColor = color.cgColor
        layer.borderWidth =  width
    }
}
