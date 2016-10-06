//
//  String+Calculations.swift
//  iamfilm
//
//  Created by Dmytro Lisitsyn on 4/13/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

extension String {
    
    func height(width: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSFontAttributeName: font]
        let height = NSString(string: self).boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).height
        return ceil(height)
    }
    
    func width(height: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let attributes = [NSFontAttributeName: font]
        let width = NSString(string: self).boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).width
        return ceil(width)
    }
}
