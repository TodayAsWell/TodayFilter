//
//  GlassesCollectionViewCell.swift
//  TodayFilter
//
//  Created by 박준하 on 2023/03/03.
//

import UIKit
import SnapKit

class GlassesCollectionViewCell: UICollectionViewCell {
    var backView: UIView!
    var glassesImageView: UIImageView!
    
    private let cornerRadius: CGFloat = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.layer.cornerRadius = cornerRadius
        
        addSubview(backView)
        addSubview(glassesImageView)
        
        backView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        glassesImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.width.equalTo(100.0)
        }
    }
    
    func setup(with imageName: String) {
        glassesImageView.image = UIImage(named: imageName)
    }
}
