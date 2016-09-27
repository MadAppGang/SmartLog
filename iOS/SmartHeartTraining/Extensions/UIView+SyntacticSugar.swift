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
    
    fileprivate static func loadViewFromNib<T: UIView>() -> T {
        let nibContent = Bundle.main.loadNibNamed(className(), owner: nil, options: nil)
        var viewToReturn: T!
        for objectFromNib in nibContent! {
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
        let objectClassNameComponents = objectClassName.components(separatedBy: ".")
        return objectClassNameComponents.last!
    }
}

extension UIStoryboard {
    
    func createViewController<T: UIViewController>(_ vc: T.Type) -> T {
        return instantiateViewController(withIdentifier: vc.storyboardId()) as! T
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
    
    func registerNibOfReusableView<T: UITableViewHeaderFooterView>(_ view: T.Type) {
        let nib = UINib(nibName: view.className(), bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: view.viewId())
    }
    
    func registerNibOfCell<T: UITableViewCell>(_ cell: T.Type) {
        let nib = UINib(nibName: cell.className(), bundle: nil)
        register(nib, forCellReuseIdentifier: cell.cellId())
    }
    
    func registerCell<T: UITableViewCell>(_ cell: T.Type) {
        register(cell, forCellReuseIdentifier: cell.cellId())
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type = T.self) -> T {
        let cell = self.dequeueReusableCell(withIdentifier: cell.cellId()) as? T
        return cell!
    }
    
    func dequeueForIndexPath<T: UITableViewCell>(_ indexPath: IndexPath, reusableCell cell: T.Type = T.self) -> T {
        let cell = self.dequeueReusableCell(withIdentifier: cell.cellId(), for: indexPath) as? T
        return cell!
    }
    
    func dequeueReusableView<T: UITableViewHeaderFooterView>(_ view: T.Type = T.self) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: view.viewId()) as! T
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
    
    func registerNibOfCell<T: UICollectionViewCell>(_ cell: T.Type) {
        let nib = UINib(nibName: cell.className(), bundle: nil)
        register(nib, forCellWithReuseIdentifier: cell.cellId())
    }
    
    func registerNibOfHeader<T: UICollectionReusableView>(_ header: T.Type) {
        let nib = UINib(nibName: header.className(), bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header.viewId())
    }
    
    func dequeueCellForIndexPath<T: UICollectionViewCell>(_ indexPath: IndexPath, reusableCell cell: T.Type = T.self) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: cell.cellId(), for: indexPath) as? T
        return cell!
    }
    
    func dequeueViewForIndexPath<T: UICollectionReusableView>(_ indexPath: IndexPath, kind: String = UICollectionElementKindSectionHeader, reusableView view: T.Type = T.self) -> T {
        let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: view.viewId(), for: indexPath) as? T
        return cell!
    }
}
