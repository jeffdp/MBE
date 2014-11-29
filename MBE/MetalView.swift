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
	var positionBuffer: MTLBuffer! = nil
	var numberOfVertices = 0
	var pipeline: MTLRenderPipelineState! = nil
	var displayLink: CADisplayLink! = nil
	
	var model = CubeModel()
	
	required init(coder aDecoder: NSCoder) {
		
		super.init(coder:aDecoder)
		
		if let ml = self.layer as? CAMetalLayer {
			self.metalLayer = ml
			
			buildDevice()
			buildVertexBuffers()
			buildPipeline()
		} else {
			assert(false, "layer is not CAMetalLayer")
		}
	}
	
	override class func layerClass() -> AnyClass {
		return CAMetalLayer.self
	}
	
	// MARK: Graphics methods
	
	func buildDevice() {
		metalLayer!.device = device
		metalLayer!.pixelFormat = .BGRA8Unorm
	}
	
	func buildVertexBuffers() {
		let positions: [Float] = model.vertices
		let positionLength = positions.count * sizeofValue(positions[0])
		numberOfVertices = positions.count
		
		// options:MTLResourceOptionCPUCacheModeDefault ?
		positionBuffer = device.newBufferWithBytes(positions, length: positionLength, options: nil)
	}
	
	func buildPipeline() {
		let library = device.newDefaultLibrary()
		let vertexFunc = library?.newFunctionWithName("vertex_main")
		let fragmentFunc = library?.newFunctionWithName("fragment_main")
		
		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.vertexFunction = vertexFunc;
		pipelineDescriptor.fragmentFunction = fragmentFunc;
		
		// colorAttachment[0] is the framebuffer that will be rendered on screen
		pipelineDescriptor.colorAttachments[0].pixelFormat = metalLayer!.pixelFormat
		
		var pipelineError: NSError?
		pipeline = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor, error: nil)
	}
	
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
		commandEncoder.setRenderPipelineState(pipeline)
		commandEncoder.setVertexBuffer(positionBuffer, offset: 0, atIndex: 0)
		commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: numberOfVertices, instanceCount: 1)
		commandEncoder.endEncoding()
		
		// Indicate that rendering is complete and drawable is ready to be executed on the GPU
		commandBuffer.presentDrawable(drawable)
		commandBuffer.commit()
	}
	
	func renderLoop() {
		autoreleasepool {
			self.redraw()
		}
	}
	
	// MARK: Lifetime methods
	
	override func didMoveToSuperview() {
		if self.superview != nil {
			displayLink = CADisplayLink(target: self, selector: Selector("renderLoop"))
			displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
		} else {
			displayLink.invalidate()
			displayLink = nil
		}
	}
	
	override func didMoveToWindow() {
		self.redraw()
	}
	
	override func awakeFromNib() {
		
	}
	
}