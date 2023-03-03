//
//  extension+String.swift
//  
//
//  Created by 박준하 on 2023/03/03.
//

import UIKit

extension String {
  
  func image() -> UIImage? {
    
    let size = CGSize(width: 20, height: 22)
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    UIColor.clear.set()
    
    let rect = CGRect(origin: .zero, size: size)
    UIRectFill(CGRect(origin: .zero, size: size))
    
    (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 15)])
    
    let image = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()
    
    return image
  }
}
