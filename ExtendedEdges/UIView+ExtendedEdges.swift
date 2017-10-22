//
//  UIView+ExtendedEdges.swift
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

public extension UIView {
    
    enum Edge {
        case top
        case leading
        case trailing
        case bottom
    }
}


// MARK: - Background View
public extension UIView {
    
    /// The view's edges that need to extended.
    ///
    /// The default value is an empty set, which means not extend any edges.
    var extendedEdges: Set<Edge> {
        get {
            return edgeExtendedLayoutGuide.extendedEdges
        }
        set {
            edgeExtendedLayoutGuide.extendedEdges = newValue
        }
    }
    
    /// The view's background view that extend to superview's edge.
    ///
    /// The default value is a view with clear background color.
    var backgroundViewForEdgeExtension: UIView {
        get {
            if let view = subviews.first(where: { $0.isBackgroundView }) {
                return view
            }
            let defaultView = EdgeExtendedBackgroundView()
            self.backgroundViewForEdgeExtension = defaultView
            return defaultView
        }
        set(view) {
            if let view = subviews.first(where: { $0.isBackgroundView }) {
                view.removeFromSuperview()
            }
            view.isBackgroundView = true
            insertSubview(view, toFillLayoutGuide: edgeExtendedLayoutGuide)
        }
    }
    
    /// The layout guide that defines `backgroundViewForEdgeExtension`'s frame.
    fileprivate var edgeExtendedLayoutGuide: EdgeExtendedLayoutGuide {
        if let layoutGuide = layoutGuides.first(where: { $0 is EdgeExtendedLayoutGuide }) as? EdgeExtendedLayoutGuide {
            return layoutGuide
        }
        let layoutGuide = EdgeExtendedLayoutGuide()
        addLayoutGuide(layoutGuide)
        return layoutGuide
    }
    
    private var isBackgroundView: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.backgroundView) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.backgroundView, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}


// MARK: - Separator
public extension UIView {
    
    /// The view's edge to place separator.
    ///
    /// Default value is `Edge.top`, which means place separator at the view's top edge.
    ///
    /// Set a new value will create and add a new separator to the view if current don't have one.
    var separatorEdge: Edge {
        get {
            return separatorLayoutGuide.attachedEdge
        }
        set {
            separatorLayoutGuide.attachedEdge = newValue
            _ = separator // create and add a new separator if current don't have one
        }
    }
    
    /// The separator view for indicated `separatorEdge`.
    ///
    /// The default value is a view with background color `UIColor.black.withAlphaComponent(0.3)` (iOS standard separator color).
    var separator: UIView {
        get {
            if let view = subviews.first(where: { $0.isSeparator }) {
                return view
            }
            let defaultView = SeparatorView()
            defaultView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.separator = defaultView
            return defaultView
        }
        set(view) {
            if let view = subviews.first(where: { $0.isSeparator }) {
                view.removeFromSuperview()
            }
            view.isSeparator = true
            insertSubview(view, toFillLayoutGuide: separatorLayoutGuide)
        }
    }
    
    /// The layout guide that defines `separator`'s frame.
    private var separatorLayoutGuide: SeparatorLayoutGuide {
        if let layoutGuide = layoutGuides.first(where: { $0 is SeparatorLayoutGuide }) as? SeparatorLayoutGuide {
            return layoutGuide
        }
        let layoutGuide = SeparatorLayoutGuide()
        addLayoutGuide(layoutGuide)
        return layoutGuide
    }
    
    private var isSeparator: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.separator) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.separator, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}


// MARK: - Private Views
private class EdgeExtendedBackgroundView : UIView {}

private class SeparatorView : UIView {}


// MARK: - Private Helper
private extension UIView {
    
    func insertSubview(_ view: UIView, toFillLayoutGuide layoutGuide: UILayoutGuide) {
        insertSubview(view, at: 0)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            view.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            ])
    }
}

private struct AssociatedKey {
    static var separator = 0
    static var backgroundView = 1
}


// MARK: - EdgeExtendedLayoutGuide
private class EdgeExtendedLayoutGuide : UILayoutGuide {
    
    var extendedEdges: Set<UIView.Edge> = [] {
        didSet {
            if extendedEdges != oldValue {
                updateConstraints()
            }
        }
    }
    
    private struct Constraints {
        var leading: NSLayoutConstraint?
        var top: NSLayoutConstraint?
        var trailing: NSLayoutConstraint?
        var bottom: NSLayoutConstraint?
        
        func deactiveAll() {
            let constraints = [leading, top, trailing, bottom].flatMap { $0 }
            NSLayoutConstraint.deactivate(constraints)
        }
        
        func constraint(at edge: UIView.Edge) -> NSLayoutConstraint? {
            switch edge {
            case .leading: return leading
            case .top: return top
            case .trailing: return trailing
            case .bottom: return bottom
            }
        }
    }
    
    private var viewMarginConstraints = Constraints(leading: nil, top: nil, trailing: nil, bottom: nil)
    
    private var superviewMarginConstraints = Constraints(leading: nil, top: nil, trailing: nil, bottom: nil)
    
    private var viewDidMoveToSuperviewObserver: Any? {
        didSet {
            guard let observer = oldValue else { return }
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    deinit {
        guard let observer = viewDidMoveToSuperviewObserver else { return }
        NotificationCenter.default.removeObserver(observer)
    }
    
    override var owningView: UIView? {
        didSet {
            guard let view = owningView else { return }
            updateConstraints()
            
            viewDidMoveToSuperviewObserver = NotificationCenter.default.addObserver(forName: .viewDidMoveToSuperview, object: view, queue: .main) { [weak self, weak view] _ in
                guard view?.superview != nil else { return }
                self?.updateConstraints()
            }
            
            struct Swizzle {
                static let perform: Void = {
                    method_exchangeImplementations(
                        class_getInstanceMethod(UIView.self, #selector(UIView.didMoveToSuperview))!,
                        class_getInstanceMethod(UIView.self, #selector(UIView.eelg_swizzle_didMoveToSuperview))!
                    )
                }()
            }
            _ = Swizzle.perform
        }
    }
    
    private func updateConstraints() {
        guard let view = owningView else { return }
        
        if viewMarginConstraints.leading == nil || viewMarginConstraints.leading?.secondItem as? UIView != view {
            viewMarginConstraints.deactiveAll()
            
            viewMarginConstraints.leading = leadingAnchor.constraint(equalTo: view.leadingAnchor)
            viewMarginConstraints.top = topAnchor.constraint(equalTo: view.topAnchor)
            viewMarginConstraints.trailing = trailingAnchor.constraint(equalTo: view.trailingAnchor)
            viewMarginConstraints.bottom = bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }
        
        if let superview = view.superview, superviewMarginConstraints.leading == nil || superviewMarginConstraints.leading?.secondItem as? UIView != superview {
            superviewMarginConstraints.deactiveAll()
            
            superviewMarginConstraints.leading = leadingAnchor.constraint(equalTo: superview.leadingAnchor)
            superviewMarginConstraints.top = topAnchor.constraint(equalTo: superview.topAnchor)
            superviewMarginConstraints.trailing = trailingAnchor.constraint(equalTo: superview.trailingAnchor)
            superviewMarginConstraints.bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        }
        
        let allEdges: [UIView.Edge] = [.leading, .top, .trailing, .bottom]
        
        for edge in allEdges {
            guard let viewMarginConstraint = viewMarginConstraints.constraint(at: edge) else { continue }
            let superviewMarginConstraint = superviewMarginConstraints.constraint(at: edge)
            
            let extendToEdge = view.superview != nil && superviewMarginConstraint != nil && extendedEdges.contains(edge)
            
            if extendToEdge {
                if viewMarginConstraint.isActive {
                    viewMarginConstraint.isActive = false
                }
                if let superviewMarginConstraint = superviewMarginConstraint, !superviewMarginConstraint.isActive {
                    superviewMarginConstraint.isActive = true
                }
            } else {
                if let superviewMarginConstraint = superviewMarginConstraint, superviewMarginConstraint.isActive {
                    superviewMarginConstraint.isActive = false
                }
                if !viewMarginConstraint.isActive {
                    viewMarginConstraint.isActive = true
                }
            }
        }
    }
}

@objc private extension UIView {
    func eelg_swizzle_didMoveToSuperview() {
        NotificationCenter.default.post(name: .viewDidMoveToSuperview, object: self)
        eelg_swizzle_didMoveToSuperview()
    }
}

private extension Notification.Name {
    static let viewDidMoveToSuperview = Notification.Name("EELGViewDidMoveToSuperviewNotification")
}

// MARK: - SeparatorLayoutGuide
private class SeparatorLayoutGuide : UILayoutGuide {
    
    var attachedEdge: UIView.Edge = .top {
        didSet {
            if attachedEdge != oldValue {
                updateConstraints()
            }
        }
    }
    
    override var owningView: UIView? {
        didSet {
            updateConstraints()
        }
    }
    
    private var constraints = [NSLayoutConstraint]()
    
    private static let separatorWidth = 1 / UIScreen.main.nativeScale
    
    private func updateConstraints() {
        guard let view = owningView else { return }
        
        NSLayoutConstraint.deactivate(constraints)
        defer { NSLayoutConstraint.activate(constraints) }
        
        let edgeLayoutGuide = view.edgeExtendedLayoutGuide
        let separatorWidth = SeparatorLayoutGuide.separatorWidth
        
        switch attachedEdge {
        case .leading:
            constraints = [
                trailingAnchor.constraint(equalTo: edgeLayoutGuide.leadingAnchor),
                topAnchor.constraint(equalTo: edgeLayoutGuide.topAnchor),
                bottomAnchor.constraint(equalTo: edgeLayoutGuide.bottomAnchor),
                widthAnchor.constraint(equalToConstant: separatorWidth),
            ]
        case .top:
            constraints = [
                bottomAnchor.constraint(equalTo: edgeLayoutGuide.topAnchor),
                leadingAnchor.constraint(equalTo: edgeLayoutGuide.leadingAnchor),
                trailingAnchor.constraint(equalTo: edgeLayoutGuide.trailingAnchor),
                heightAnchor.constraint(equalToConstant: separatorWidth),
            ]
        case .trailing:
            constraints = [
                leadingAnchor.constraint(equalTo: edgeLayoutGuide.trailingAnchor),
                topAnchor.constraint(equalTo: edgeLayoutGuide.topAnchor),
                bottomAnchor.constraint(equalTo: edgeLayoutGuide.bottomAnchor),
                widthAnchor.constraint(equalToConstant: separatorWidth),
            ]
        case .bottom:
            constraints = [
                topAnchor.constraint(equalTo: edgeLayoutGuide.bottomAnchor),
                leadingAnchor.constraint(equalTo: edgeLayoutGuide.leadingAnchor),
                trailingAnchor.constraint(equalTo: edgeLayoutGuide.trailingAnchor),
                heightAnchor.constraint(equalToConstant: separatorWidth),
            ]
        }
    }
}
