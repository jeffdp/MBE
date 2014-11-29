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
	var colorBuffer: MTLBuffer! = nil
	var pipeline: MTLRenderPipelineState! = nil
	
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
		let positions: [Float] = [
			 0.0,  0.5, 0.0, 1.0,
			-0.5, -0.5, 0.0, 1.0,
			 0.5, -0.5, 0.0, 1.0
		]
		let positionLength = positions.count * sizeofValue(positions[0])
		
		let colors: [Float] = [
			1, 0, 0, 1,
			0, 1, 0, 1,
			0, 0, 1, 1
		]
		let colorLength = colors.count * sizeofValue(colors[0])
		
		// options:MTLResourceOptionCPUCacheModeDefault ?
		positionBuffer = device.newBufferWithBytes(positions, length: positionLength, options: nil)
		
		colorBuffer = device.newBufferWithBytes(colors, length: colorLength, options: nil)
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
		commandEncoder.setVertexBuffer(colorBuffer, offset: 0, atIndex: 1)
		commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
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