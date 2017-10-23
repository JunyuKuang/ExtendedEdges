//
//  ViewController.swift
//  ExtendedEdges
//
//  Copyright (c) 2017 Junyu Kuang <lightscreen.app@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

class ViewController: UIViewController {
    
    // MARK: -
    
    override func loadView() {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Wallpaper")
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        view = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(buttonBar)
        
        buttonBar.tintColor = .white
        buttonBar.backgroundViewForEdgeExtension = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        barAdjustmentConstraints = BarAdjustmentConstraints(top: buttonBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                                                            center: buttonBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                                            bottom: buttonBar.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor))
        NSLayoutConstraint.activate([
            buttonBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            buttonBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            buttonBar.heightAnchor.constraint(equalToConstant: 44),
            barAdjustmentConstraints!.bottom,
            ])
        
        barPosition = .bottom
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: -
    
    private lazy var buttonForTopLayout: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Top", for: .normal)
        button.addTarget(self, action: #selector(placeBarOnTop), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonForCenterLayout: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Center", for: .normal)
        button.addTarget(self, action: #selector(placeBarOnCenter), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonForBottomLayout: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Bottom", for: .normal)
        button.addTarget(self, action: #selector(placeBarOnBottom), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonBar: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [buttonForTopLayout, buttonForCenterLayout, buttonForBottomLayout])
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    
    // MARK: -
    
    private struct BarAdjustmentConstraints {
        let top: NSLayoutConstraint
        let center: NSLayoutConstraint
        let bottom: NSLayoutConstraint
        
        func deactiveAll() {
            [top, center, bottom].forEach { $0.isActive = false }
        }
    }
    
    private var barAdjustmentConstraints: BarAdjustmentConstraints?
    
    private enum BarPosition {
        case top, center, bottom
    }
    
    private var barPosition = BarPosition.bottom {
        didSet {
            self.buttonBar.superview?.layoutIfNeeded()
            performAnimations {
                self.barAdjustmentConstraints?.deactiveAll()
                
                [self.buttonForTopLayout, self.buttonForCenterLayout, self.buttonForBottomLayout].forEach { $0.isEnabled = true }
                
                switch self.barPosition {
                case .top:
                    self.buttonBar.extendedEdges = [.leading, .trailing, .top]
                    self.barAdjustmentConstraints?.top.isActive = true
                    self.buttonForTopLayout.isEnabled = false
                    
                case .center:
                    self.buttonBar.extendedEdges = [.leading, .trailing]
                    self.barAdjustmentConstraints?.center.isActive = true
                    self.buttonForCenterLayout.isEnabled = false
                    
                case .bottom:
                    self.buttonBar.extendedEdges = [.leading, .trailing, .bottom]
                    self.barAdjustmentConstraints?.bottom.isActive = true
                    self.buttonForBottomLayout.isEnabled = false
                }
                
                self.buttonBar.superview?.layoutIfNeeded()
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
}

// MARK: -
@objc private extension ViewController {
    
    func placeBarOnTop() {
        barPosition = .top
    }
    
    func placeBarOnCenter() {
        barPosition = .center
    }
    
    func placeBarOnBottom() {
        barPosition = .bottom
    }
}

private func performAnimations(_ animations: @escaping () -> ()) {
    if #available(iOS 10.0, *) {
        UIViewPropertyAnimator(duration: 0.5,
                               dampingRatio: 1,
                               animations: animations).startAnimation()
    } else {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       animations: animations)
    }
}
