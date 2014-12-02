//
//  Shaders.metal
//  MetalSwift
//
//  Created by Seth Sowerby on 8/14/14.
//  Copyright (c) 2014 Seth Sowerby. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct Uniforms {
	float4x4 modelMatrix;
	float4x4 projectionMatrix;
};

struct Vertex
{
	float4 position [[position]];
};

vertex Vertex vertex_main(constant float4 *position [[buffer(0)]],
						  constant Uniforms &uniforms [[buffer(1)]],
						  uint vid [[vertex_id]])
{
	float4x4 mv_Matrix = uniforms.modelMatrix;
	float4x4 proj_matrix = uniforms.projectionMatrix;
	
	Vertex vert;
//	vert.position = proj_matrix * mv_Matrix * position[vid];
	
	vert.position = position[vid];
	
	return vert;
}

fragment float4 fragment_main(Vertex vert [[stage_in]])
{
	return float4(1, 0, 0, 1);
}