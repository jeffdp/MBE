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
	float4 normal;
};

vertex Vertex vertex_main(constant packed_float3 *position [[buffer(0)]],
						  constant packed_float3 *normal [[buffer(1)]],
						  constant Uniforms &uniforms [[buffer(2)]],
						  uint vid [[vertex_id]])
{
	float4x4 mv_Matrix = uniforms.modelMatrix;
	float4x4 proj_matrix = uniforms.projectionMatrix;
	
	Vertex vert;
	vert.position = proj_matrix * mv_Matrix * float4(position[vid], 1.0);
	
	vert.normal = float4(normal[vid], 1.0);
	
	return vert;
}

fragment float4 fragment_main(Vertex vert [[stage_in]])
{
	float3 diffuse = float3(1, 0, 0);
	
	return float4(diffuse, 1);
}