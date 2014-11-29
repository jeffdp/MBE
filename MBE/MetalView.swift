//
//  MetalView.swift
//  MBE
//
//  Created by Jeff Porter on 11/29/14.
//  Copyright (c) 2014 Jeff Porter. All rights reserved.
//

import UIKit

class MetalView : UIView {
	
	let device = MTLCreateSystemDefaultDevice()
	var metalLayer: CAMetalLayer?
	
	required init(coder aDecoder: NSCoder) {
		
		super.init(coder:aDecoder)
		
		if let ml = self.layer as? CAMetalLayer {
			self.metalLayer = ml
			
			metalLayer!.device = device
			metalLayer!.pixelFormat = .BGRA8Unorm
		} else {
			assert(false, "layer is not CAMetalLayer")
		}
	}
	
	override class func layerClass() -> AnyClass {
		return CAMetalLayer.self
	}
	
	// MARK: Graphics methods
	
	func redraw() {
		// Get the next displayable buffer (texture)
		let drawable = metalLayer!.nextDrawable()
		let texture = drawable.texture
		
		let clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
		
		let passDescriptor = MTLRenderPassDescriptor()
		passDescriptor.colorAttachments[0].texture = texture
		passDescriptor.colorAttachments[0].loadAction = .Clear
		passDescriptor.colorAttachments[0].storeAction = .Store
		passDescriptor.colorAttachments[0].clearColor = clearColor
		
		// Command queue keeps a list of render command buffers (can be long lived)
		let commandQueue = device.newCommandQueue()
		
		// Command buffer represents collection of render commands
		let commandBuffer = commandQueue.commandBuffer()
		
		// Command encoder tells Metal what drawing we want to do
		let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(passDescriptor)!
		commandEncoder.endEncoding()
		
		// Indicate that rendering is complete and drawable is ready to be executed on the GPU
		commandBuffer.presentDrawable(drawable)
		commandBuffer.commit()
	}
	
	// MARK: Lifetime methods
	
	override func didMoveToWindow() {
		self.redraw()
	}
	
	override func awakeFromNib() {
		
	}
	
}