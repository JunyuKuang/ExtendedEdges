# ExtendedEdges
A simple and easy way to keep your custom views layout properly on iPhone X.

Demo video: [YouTube](https://youtu.be/Wp9C1b0r3BA)


## Requirement
- Xcode 9.0+
- Swift 4.0+
- iOS 9.0+


## Installation
1. Download the project
2. Open the project, then drag the `UIView+ExtendedEdges.swift` file into your project.


## Usages
The APIs are simple.
Use 2 properties to configure extended edges, and 2 (optional) properties to configure separator.
Check `ViewController.swift` in project for detail usages.

``` swift
public extension UIView {

    enum Edge {
        case top
        case leading
        case trailing
        case bottom
    }
}

public extension UIView {

    /// The view's edges that need to extended.
    ///
    /// The default value is an empty set, which means not extend any edges.
    var extendedEdges: Set<Edge> { get set }

    /// The view's background view that extend to outside of the `safeAreaLayoutGuide`.
    ///
    /// The default value is a view with clear background color.
    var backgroundViewForEdgeExtension: UIView { get set }
}

public extension UIView {

    /// The view's edge to place separator.
    ///
    /// Default value is `Edge.top`, which means place separator at the view's top edge.
    ///
    /// Set a new value will create and add a new separator to the view if current don't have one.
    var separatorEdge: Edge { get set }

    /// The separator view for indicated `separatorEdge`.
    ///
    /// The default value is a view with background color `UIColor.black.withAlphaComponent(0.3)` (iOS standard separator color).
    var separator: UIView { get set }
}
```

### Example
``` swift
let yourCustomToolbar = UIView()
view.addSubview(yourCustomToolbar)

// configure Auto Layout constraints
yourCustomToolbar.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    yourCustomToolbar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
    yourCustomToolbar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
    yourCustomToolbar.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
    yourCustomToolbar.heightAnchor.constraint(equalToConstant: 64),
    ])

// configure extended edges and background view
yourCustomToolbar.extendedEdges = [.leading, .trailing, .bottom]
yourCustomToolbar.backgroundViewForEdgeExtension = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

// add a separator to view's top edge
yourCustomToolbar.separatorEdge = .top
```

# License - MIT
Copyright (c) 2017 Junyu Kuang <lightscreen.app@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
