import Foundation
import UIKit

public enum ActivityIndicatorType {
    case none
    case activity
    case custom(ActivityIndicatorProvider)
}

@MainActor
/// An indicator type which can be used to show the download task is in progress.
public protocol ActivityIndicatorProvider {
    /// Called when the indicator should start animating.
    func startAnimatingView()

    /// Called when the indicator should stop animating.
    func stopAnimatingView()

    /// The indicator view which would be added to the super view.
    var view: UIView { get }

    /// The size strategy used when adding the indicator to a view.
    /// - Parameter view: The super view of indicator.
    func sizeStrategy(in view: UIView) -> ActivityIndicatorSizeStrategy
}

public enum ActivityIndicatorSizeStrategy {
    case intrinsicSize
    case full
    case size(CGSize)
}

@MainActor
final class DefaultActivityIndicatorProvider: ActivityIndicatorProvider {
    private let activityIndicatorView: UIActivityIndicatorView

    init() {
        self.activityIndicatorView = UIActivityIndicatorView(style: .medium)
    }

    func startAnimatingView() {
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
    }

    func stopAnimatingView() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }

    var view: UIView {
        activityIndicatorView
    }

    func sizeStrategy(in view: UIView) -> ActivityIndicatorSizeStrategy {
        .intrinsicSize
    }
}
