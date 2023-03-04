//
//  Extension+Collection.swift
//  TodayFilter
//
//  Created by 박준하 on 2023/03/04.
//

import Foundation

extension Collection where Element == SIMD3<Float> {
    func average() -> SIMD3<Float>? {
        guard !isEmpty else { return nil }
        let sum = reduce(SIMD3<Float>()) { $0 + $1 }
        return sum / Float(count)
    }
}
