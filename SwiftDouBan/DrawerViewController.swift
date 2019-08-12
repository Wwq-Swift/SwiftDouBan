//
//  DrawerViewController.swift
//  SwiftDouBan
//
//  Created by 王伟奇 on 2019/8/13.
//  Copyright © 2019 王伟奇. All rights reserved.
//

import UIKit
//import UIKit.UIGestureRecognizerSubclass

/// 抽屉控制器
class DrawerViewController: UIViewController {
    
    /// 抽屉视图
    lazy var drawerView: UIView = {
        let view = UIView()
        /// 采用自动布局
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red///UIColor(white: 0.3, alpha: 1)
        return view
    }()
    /// 抽屉关闭的状态可以看见的高度
    var closeVisableHeight: CGFloat = 60
    /// 抽屉距离顶部的高度
    var drawViewTopMargin: CGFloat = 80
    
    private let panRecognier = InstantPanGestureRecognizer()
    
    /// 采用属性动画
    private var animator = UIViewPropertyAnimator()
    
    /// 标记当前抽屉是否打开
    private var isOpen = false
    private var animationProgress: CGFloat = 0
    
    /// 关闭的状态
    private var closedTransform: CGAffineTransform = .identity
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.contents = UIImage(named: "movie_back")?.cgImage
        setupUI()
        configue()
    }
    
    /// 手势触发处理
    @objc private func panned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:  /// 开启动画，并暂停
            startAnimation()
            animator.pauseAnimation()
            animationProgress = animator.fractionComplete
        case .changed:
            var fraction = -recognizer.translation(in: drawerView).y / closedTransform.ty
            if isOpen { fraction *= -1 }
            if animator.isReversed { fraction *= -1 } /// 是否是反方向
            animator.fractionComplete = fraction + animationProgress
        case .ended, .cancelled:
            /// y 轴方向的速度
            let yVelocity = recognizer.velocity(in: drawerView).y
            /// 根据速度来判断是否关闭 （可以控制大于多少速度时关闭）
            let shouldClose = yVelocity > 0
            if yVelocity == 0 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
            if isOpen {
                if !shouldClose && !animator.isReversed { animator.isReversed.toggle() }
                if shouldClose && animator.isReversed { animator.isReversed.toggle() }
            } else {
                if shouldClose && !animator.isReversed { animator.isReversed.toggle() }
                if !shouldClose && animator.isReversed { animator.isReversed.toggle() }
            }
            /// 动画剩余未完成的比例。（fractionComplete 动画已经完成的比例）
            let fractionRemaining = 1 - animator.fractionComplete
            /// 动画还需要移动多少距离才完成
            let distanceRemaining = fractionRemaining * closedTransform.ty
            if distanceRemaining == 0 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
            let relativeVelocity = min(abs(yVelocity) / distanceRemaining, 30)
            let timingParameters = UISpringTimingParameters(damping: 0.8, response: 0.3, initialVelocity: CGVector(dx: 0, dy: relativeVelocity))
            let preferredDuration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
            let durationFactor = CGFloat(preferredDuration / animator.duration)
            animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: durationFactor)
        default:
            break
        }
    }
    
    /// 开始动画
    private func startAnimation() {
        /// 如果动画正常执行，什么都不处理
        if animator.isRunning { return }
        let timingParameters = UISpringTimingParameters(damping: 1, response: 0.4)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            /// 根据是打开还是关闭进行对应的位置转换
            self.drawerView.transform = self.isOpen ? self.closedTransform : .identity
        }
        /// 动画完成，改变状态
        animator.addCompletion { position in
            if position == .end { self.isOpen.toggle() }
        }
        animator.startAnimation()
    }
}

extension DrawerViewController {
    private func setupUI() {
        view.addSubview(drawerView)
        drawerView.layer.contents = UIImage(named: "comment_icon")?.cgImage
        drawerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        drawerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0).isActive = true
        drawerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        drawerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: drawViewTopMargin).isActive = true
        
        /// 小短线
        let handleView = UIView()
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        handleView.layer.cornerRadius = 3
        
        drawerView.addSubview(handleView)
        handleView.topAnchor.constraint(equalTo: drawerView.topAnchor, constant: 10).isActive = true
        handleView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        handleView.centerXAnchor.constraint(equalTo: drawerView.centerXAnchor).isActive = true
        
        
    }
    
    private func configue() {
        
        /// 设置关闭状态的位置转换
        closedTransform = CGAffineTransform(translationX: 0, y: view.bounds.height - drawViewTopMargin - closeVisableHeight - (navigationController?.navigationBar.frame.height ?? 0) - 60)
        drawerView.transform = closedTransform
        panRecognier.addTarget(self, action: #selector(panned))
        drawerView.addGestureRecognizer(panRecognier)
    }
}


class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        /// 控制单击状态
        self.state = .began
    }
    
}



