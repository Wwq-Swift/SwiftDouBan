//
//  UISpringTimingParameters + Extension.swift
//  SwiftDouBan
//
//  Created by 王伟奇 on 2019/8/13.
//  Copyright © 2019 王伟奇. All rights reserved.
//

import UIKit.UIGestureRecognizer

extension UISpringTimingParameters {
    
    ///  便利创建缓冲曲线方法
    ///
    /// - Parameters:
    ///   - damping: 动画阻尼 必须 0 - 1
    ///   - response: 动画速度
    ///   - initialVelocity: 起始动画向量
    public convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}
