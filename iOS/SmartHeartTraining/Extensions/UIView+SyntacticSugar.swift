//
//  UIView+SyntacticSugar.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

extension UIView {
    
    static func loadFromNib() -> Self {
        return loadViewFromNib()
    }
    
    private static func loadViewFromNib<T: UIView>() -> T {
        let nibContent = NSBundle.mainBundle().loadNibNamed(className(), owner: nil, options: nil)
        var viewToReturn: T!
        for objectFromNib in nibContent {
            if let viewFromNib = objectFromNib as? T {
                viewToReturn = viewFromNib
            }
        }
        return viewToReturn
    }
}

extension NSObject {
    
    static func className() -> String {
        let objectClass: AnyClass = self
        let objectClassName = NSStringFromClass(objectClass)
        let objectClassNameComponents = objectClassName.componentsSeparatedByString(".")
        return objectClassNameComponents.last!
    }
}

extension UIStoryboard {
    
    func createViewController<T: UIViewController>(vc: T.Type) -> T {
        return instantiateViewControllerWithIdentifier(vc.storyboardId()) as! T
    }
}

extension UIViewController {
    
    static func storyboardId() -> String {
        return className()
    }
}

extension UITableViewCell {
    
    static func cellId() -> String {
        return className()
    }
}

extension UITableViewHeaderFooterView {
    
    static func viewId() -> String {
        return className()
    }
}

extension UITableView {
    
    func registerNibOfReusableView<T: UITableViewHeaderFooterView>(view: T.Type) {
        let nib = UINib(nibName: view.className(), bundle: nil)
        registerNib(nib, forHeaderFooterViewReuseIdentifier: view.viewId())
    }
    
    func registerNibOfCell<T: UITableViewCell>(cell: T.Type) {
        let nib = UINib(nibName: cell.className(), bundle: nil)
        registerNib(nib, forCellReuseIdentifier: cell.cellId())
    }
    
    func registerCell<T: UITableViewCell>(cell: T.Type) {
        registerClass(cell, forCellReuseIdentifier: cell.cellId())
    }
    
    func dequeueReusableCell<T: UITableViewCell>(cell: T.Type = T.self) -> T {
        let cell = dequeueReusableCellWithIdentifier(cell.cellId()) as? T
        return cell!
    }
    
    func dequeueForIndexPath<T: UITableViewCell>(indexPath: NSIndexPath, reusableCell cell: T.Type = T.self) -> T {
        let cell = dequeueReusableCellWithIdentifier(cell.cellId(), forIndexPath: indexPath) as? T
        return cell!
    }
    
    func dequeueReusableView<T: UITableViewHeaderFooterView>(view: T.Type = T.self) -> T {
        return dequeueReusableHeaderFooterViewWithIdentifier(view.viewId()) as! T
    }
}

extension UICollectionViewCell {
    
    static func cellId() -> String {
        return className()
    }
}

extension UICollectionReusableView {
    
    static func viewId() -> String {
        return className()
    }
}


extension UICollectionView {
    
    func registerNibOfCell<T: UICollectionViewCell>(cell: T.Type) {
        let nib = UINib(nibName: cell.className(), bundle: nil)
        registerNib(nib, forCellWithReuseIdentifier: cell.cellId())
    }
    
    func registerNibOfHeader<T: UICollectionReusableView>(header: T.Type) {
        let nib = UINib(nibName: header.className(), bundle: nil)
        registerNib(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header.viewId())
    }
    
    func dequeueCellForIndexPath<T: UICollectionViewCell>(indexPath: NSIndexPath, reusableCell cell: T.Type = T.self) -> T {
        let cell = dequeueReusableCellWithReuseIdentifier(cell.cellId(), forIndexPath: indexPath) as? T
        return cell!
    }
    
    func dequeueViewForIndexPath<T: UICollectionReusableView>(indexPath: NSIndexPath, kind: String = UICollectionElementKindSectionHeader, reusableView view: T.Type = T.self) -> T {
        let cell = dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: view.viewId(), forIndexPath: indexPath) as? T
        return cell!
    }
}
