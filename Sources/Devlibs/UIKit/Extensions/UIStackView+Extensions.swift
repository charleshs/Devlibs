#if os(iOS) || os(tvOS)
import UIKit

extension UIStackView {
    /// A convenient initializer that assigns the `axis`, `alignment`, `distribution`, and `spacing` to the stack view after instantiated.
    /// - Parameters:
    ///   - axis: The axis along which the arranged views are laid out.
    ///   - alignment: The alignment of the arranged subviews perpendicular to the stack view’s axis.
    ///   - distribution: The distribution of the arranged views along the stack view’s axis.
    ///   - spacing: The distance in points between the adjacent edges of the stack view’s arranged views.
    public convenience init(
        axis: NSLayoutConstraint.Axis,
        alignment: UIStackView.Alignment,
        distribution: UIStackView.Distribution,
        spacing: CGFloat
    ) {
        self.init()
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }

    /// Adds a list of views to the `arrangedSubviews` array of the stack view.
    /// - Parameter views: Views to be added.
    public func addArrangedSubviews(_ views: [UIView]) {
        views.forEach(addArrangedSubview(_:))
    }

    /// Removes all views from the `arrangedSubviews` array of the stack view.
    public func removeAllArrangedSubviews() {
        arrangedSubviews.forEach(removeArrangedSubview(_:))
    }

    /// Appends the view to the `arrangedSubviews` array of the stack view with custom spacing.
    /// - Parameters:
    ///   - subview: The view to be added to the array `arrangedSubviews` of the stack view.
    ///   - spacingPrev: The spacing between the appended view and the view prior to it (if exists). Use `spacing` if passing `nil`
    ///   - spacingNext: The spacing between the appended view and the next view (if exists). Use `spacing` if passing `nil`
    @available(iOS 11.0, tvOS 11.0, *)
    public func addArrangedSubview(_ subview: UIView, spacingPrev: CGFloat?, spacingNext: CGFloat?) {
        if let previousView = arrangedSubviews.last {
            setCustomSpacing(spacingPrev ?? spacing, after: previousView)
        }
        addArrangedSubview(subview)
        setCustomSpacing(spacingNext ?? spacing, after: subview)
    }

    /// Adds the provided view to the array of arranged subviews at the specified index with custom spacings on both ends.
    /// - Parameters:
    ///   - subview: The view to be added to the array `arrangedSubviews` of the stack view.
    ///   - index: The index where the `subview` is inserted in the `arrangedSubviews` array.
    ///   - spacingPrev: The spacing between the appended view and the view prior to it (if exists). Use `spacing` if passing `nil`
    ///   - spacingNext: The spacing between the appended view and the next view (if exists). Use `spacing` if passing `nil`
    @available(iOS 11.0, tvOS 11.0, *)
    public func insertArrangedSubview(_ subview: UIView, at index: Int, spacingPrev: CGFloat?, spacingNext: CGFloat?) {
        insertArrangedSubview(subview, at: index)
        if index > 0 {
            setCustomSpacing(spacingPrev ?? spacing, after: arrangedSubviews[arrangedSubviews.index(before: index)])
        }
        setCustomSpacing(spacingNext ?? spacing, after: subview)
    }

    /// Adds the provided view to the array of arranged subviews before an existing view with custom spacings on both ends.
    /// - Parameters:
    ///   - subview: The view to be added to the array `arrangedSubviews` of the stack view.
    ///   - existingView: The view that's been present in the `arrangedSubviews` of the stack view.
    ///   - spacingPrev: The spacing between the appended view and the view prior to it (if exists). Use `spacing` if passing `nil`
    ///   - spacingNext: The spacing between the appended view and the next view (if exists). Use `spacing` if passing `nil`
    @available(iOS 11.0, tvOS 11.0, *)
    public func insertArrangedSubview(_ subview: UIView, before existingView: UIView, spacingPrev: CGFloat?, spacingNext: CGFloat?) {
        guard prepareAndCheckIfInsertable(insertingView: subview, existingView: existingView),
              let index = arrangedSubviews.firstIndex(of: existingView)
        else { return }

        insertArrangedSubview(subview, at: index)
        setCustomSpacing(spacingNext ?? spacing, after: subview)
        if index > 0 {
            setCustomSpacing(spacingPrev ?? spacing, after: arrangedSubviews[arrangedSubviews.index(before: index)])
        }
    }

    /// Adds the provided view to the array of arranged subviews after an existing view with custom spacings on both ends.
    /// - Parameters:
    ///   - subview: The view to be added to the array `arrangedSubviews` of the stack view.
    ///   - existingView: The view that's been present in the `arrangedSubviews` of the stack view.
    ///   - spacingPrev: The spacing between the appended view and the view prior to it (if exists). Use `spacing` if passing `nil`
    ///   - spacingNext: The spacing between the appended view and the next view (if exists). Use `spacing` if passing `nil`
    @available(iOS 11.0, tvOS 11.0, *)
    public func insertArrangedSubview(_ subview: UIView, after existingView: UIView, spacingPrev: CGFloat?, spacingNext: CGFloat?) {
        guard prepareAndCheckIfInsertable(insertingView: subview, existingView: existingView),
              let index = arrangedSubviews.firstIndex(of: existingView)
        else { return }

        insertArrangedSubview(subview, at: index.advanced(by: 1))
        setCustomSpacing(spacingPrev ?? spacing, after: existingView)
        setCustomSpacing(spacingNext ?? spacing, after: subview)
    }

    /// Checks if the insertion can happen and prepares the `arrangedSubviews` for insertion if insertable.
    /// - Parameters:
    ///   - insertingView: The view to be inserted.
    ///   - existingView: The reference view.
    /// - Returns: A boolean indicating if the insertion is allowed.
    ///
    /// - Time complexity: O(n) ~ O(2n) where `n` is the number of subviews in `arrangedSubviews`.
    private func prepareAndCheckIfInsertable(insertingView: UIView, existingView: UIView) -> Bool {
        let arrangedSubviewsSet = Set<UIView>(arrangedSubviews)

        guard insertingView !== existingView,
              arrangedSubviewsSet.contains(existingView)
        else { return false }

        if arrangedSubviewsSet.contains(insertingView) {
            removeArrangedSubview(insertingView)
        }
        return true
    }
}
#endif
