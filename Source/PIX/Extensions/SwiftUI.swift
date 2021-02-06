//
//  SwiftUI.swift
//  
//
//  Created by Anton Heestand on 2021-01-15.
//

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

#if os(macOS)
public typealias UINSView = NSView
#else
public typealias UINSView = UIView
#endif

#if os(macOS)
public typealias UINSViewController = NSViewController
public typealias UINSHostingView = NSHostingView
public typealias UINSViewRepresentable = NSViewRepresentable
#else
public typealias UINSViewController = UIViewController
public typealias UINSHostingView = UIHostingController
public typealias UINSViewRepresentable = UIViewRepresentable
#endif


public protocol PIXViewable: UINSViewRepresentable {
    var pixView: PIXView! { get }
}

extension PIXViewable {
    
    public func makeView(context: Context) -> PIXView {
        pixView
    }
    public func updateView(_ pixView: PIXView, context: Context) {
        print("<<< PixelKit SwiftUI Update >>>")
        guard let pix: PIX = pixView.pix else { return }
        pix.setNeedsRender()
    }
    
    #if os(macOS)
    public func makeNSView(context: Context) -> PIXView {
        makeView(context: context)
    }
    public func updateNSView(_ nsView: PIXView, context: Context) {
        updateView(nsView, context: context)
    }
    #else
    public func makeUIView(context: Context) -> PIXView {
        makeView(context: context)
    }
    public func updateUIView(_ uiView: PIXView, context: Context) {
        updateView(uiView, context: context)
    }
    #endif
    
}

struct UINSViewView: UINSViewRepresentable {
    let view: UINSView
    func makeUIView(context: Context) -> UINSView {
        view
    }
    func updateUIView(_ uiView: UINSView, context: Context) {}
}

//public struct PIXRender: UINSViewRepresentable {
//    
//    let pix: () -> (PIX)
//    
//    public init(pix: @escaping () -> (PIX)) {
//        self.pix = pix
//    }
//
//    public func makeUIView(context: Context) -> PIXView {
//        context.coordinator.pix.pixView
//    }
//
//    public func updateUIView(_ uiView: PIXView, context: Context) {
//        print("{{{ PixelKit SwiftUI Update }}}")
//    }
//    
//    public func makeCoordinator() -> Coordinator {
//        Coordinator(pix: pix())
//    }
//    
//    public class Coordinator {
//        let pix: PIX
//        public init(pix: PIX) {
//            self.pix = pix
//        }
//    }
//
//}
