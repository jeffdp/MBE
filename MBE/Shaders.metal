//
//  Shaders.metal
//  MetalSwift
//
//  Created by Seth Sowerby on 8/14/14.
//  Copyright (c) 2014 Seth Sowerby. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct Vertex
{
	float4 position [[position]];
};

vertex Vertex vertex_main(constant float4 *position [[buffer(0)]],
								 constant float4 *color [[buffer(1)]],
								 uint vid [[vertex_id]])
{
	Vertex vert;
	vert.position = position[vid];
	
	return vert;
}

fragment float4 fragment_main(Vertex vert [[stage_in]])
{
	return float4(1, 0, 0, 1);
}