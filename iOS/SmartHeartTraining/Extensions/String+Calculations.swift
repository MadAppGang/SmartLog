//
//  String+Calculations.swift
//  iamfilm
//
//  Created by Dmytro Lisitsyn on 4/13/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

extension String {
    
    func height(width width: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.max)
        let attributes = [NSFontAttributeName: font]
        let height = ceil(NSString(string: self).boundingRectWithSize(size, options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: attributes, context: nil).height)
        return height
    }
    
    func width(height height: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: CGFloat.max, height: height)
        let attributes = [NSFontAttributeName: font]
        let width = ceil(NSString(string: self).boundingRectWithSize(size, options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: attributes, context: nil).width)
        return width
    }
}
