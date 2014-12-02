//
//  CubeModel.swift
//  MBE
//
//  Created by Jeff Porter on 11/29/14.
//  Copyright (c) 2014 Jeff Porter. All rights reserved.
//

import Foundation

class CubeModel {
	init() {
		
	}
	
	var vertices: [Float] {
		get {
			return [
				//Left
				-1, -1, -1,
				-1, 1, -1,
				-1, 1, 1,
				-1, -1, 1,
				
				//Right
				1, -1, 1,
				1, 1, 1,
				1, 1, -1,
				1, -1, -1,
				
				//Bottom
				-1, -1, -1,
				-1, -1, 1,
				1, -1, 1,
				1, -1, -1,
				
				//Top
				-1, 1, -1,
				1, 1, -1,
				1, 1, 1,
				-1, 1, 1,
				
				//Back
				1, -1, -1,
				1, 1, -1,
				-1, 1, -1,
				-1, -1, -1,
				
				//Front
				-1, -1, 1,
				-1, 1, 1,
				1, 1, 1,
				1, -1, 1
			]
		}
	}
	
	var normals: [Float] {
		get {
			return [
				//Left
				-1, 0, 0,
				-1, 0, 0,
				-1, 0, 0,
				-1, 0, 0,
				
				//Right
				1, 0, 0,
				1, 0, 0,
				1, 0, 0,
				1, 0, 0,
				
				//Bottom
				0, -1, 0,
				0, -1, 0,
				0, -1, 0,
				0, -1, 0,
				
				//Top
				0, 1, 0,
				0, 1, 0,
				0, 1, 0,
				0, 1, 0,
				
				//Back
				0, 0, -1,
				0, 0, -1,
				0, 0, -1,
				0, 0, -1,
				
				//Front
				0, 0, 1,
				0, 0, 1,
				0, 0, 1,
				0, 0, 1
			]
		}
	}
	
	var indices: [UInt16] {
		get {
			return [
				//Left
				0, 1, 2,
				0, 2, 3,
				
				//Right
				4, 5, 6,
				4, 6, 7,
				
				//Bottom
				8, 9, 10,
				8, 10, 11,
				
				//Top
				12, 13, 14,
				12, 14, 15,
				
				//Back
				16, 17, 18,
				16, 18, 19,
				
				//Front
				20, 21, 22,
				20, 22, 23
			]
		}
	}
}