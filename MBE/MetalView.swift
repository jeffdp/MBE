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
	var uniformBuffer: MTLBuffer! = nil
	var indexBuffer: MTLBuffer! = nil
	
	var numberOfVertices = 0
	var pipeline: MTLRenderPipelineState! = nil
	var displayLink: CADisplayLink! = nil
	
	var model = CubeModel()
	
	var projectionMatrix: Matrix4!
	
	required init(coder aDecoder: NSCoder) {
		
		super.init(coder:aDecoder)
		
		if let ml = self.layer as? CAMetalLayer {
			self.metalLayer = ml
			
			buildDevice()
			buildVertexBuffers()
			buildPipeline()
			setupCamera()
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
		
		// options:MTLResourceOptionCPUCacheModeDefault ?
		positionBuffer = device.newBufferWithBytes(positions, length: positionLength, options: nil)
		
		let indices: [UInt16] = model.indices
		let indexLength = indices.count * sizeofValue(indices[0])
		indexBuffer = device.newBufferWithBytes(indices, length: indexLength, options: nil)
		
		numberOfVertices = indices.count
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
	
	func setupCamera() {
		projectionMatrix = Matrix4.makePerspectiveViewAngle(
			Matrix4.degreesToRad(85.0),
			aspectRatio: Float(self.bounds.size.width/self.bounds.size.height),
			nearZ: 0.01,
			farZ: 100.0)
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
		
		// TODO: We should store the buffer data and only update it as needed
		var nodeModelMatrix = modelMatrix()
		uniformBuffer = device.newBufferWithLength(sizeof(Float) * Matrix4.numberOfElements() * 2, options: nil)
		var bufferPointer = uniformBuffer?.contents()
		memcpy(bufferPointer!, nodeModelMatrix.raw(),
			UInt(sizeof(Float) * Matrix4.numberOfElements()))
		memcpy(bufferPointer! + sizeof(Float)*Matrix4.numberOfElements(), projectionMatrix.raw(), UInt(sizeof(Float)*Matrix4.numberOfElements()))
		
		commandEncoder.setVertexBuffer(self.uniformBuffer, offset: 0, atIndex: 1)
		
		commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: numberOfVertices, instanceCount: 1)
		
		let start = 0 * sizeof(UInt16)
		let count = numberOfVertices
		commandEncoder.drawIndexedPrimitives(.Triangle, indexCount: count, indexType: MTLIndexType.UInt16,
			indexBuffer: indexBuffer, indexBufferOffset: start, instanceCount: 1)
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
	
	// TODO: Move this into the model class
	
	func modelMatrix() -> Matrix4 {
		var matrix = Matrix4()
		
		matrix.translate(0, y: 0, z: -3)
		matrix.rotateAroundX(22.5, y: 0, z: 0)
		matrix.scale(0.5, y: 0.5, z: 0.5)
		
		return matrix
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