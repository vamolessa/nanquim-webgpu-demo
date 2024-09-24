////////////////////////////////////////////////////////////////////////////////////////////////////
// CONFIG
////////////////////////////////////////////////////////////////////////////////////////////////////

const WASM_MEMORY_PAGE_SIZE = 64 << 10 /* KB */;
const WASM_MEMORY_SIZE = 512 << 20 /* MB */;
const WASM_MEMORY_PAGES_LEN = WASM_MEMORY_SIZE / WASM_MEMORY_PAGE_SIZE;

////////////////////////////////////////////////////////////////////////////////////////////////////
// STATE
////////////////////////////////////////////////////////////////////////////////////////////////////

export const IS_LOCALHOST =
	location.hostname === "localhost" ||
	location.hostname === "127.0.0.1";

export const STATE = {
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// REFERENCES
	////////////////////////////////////////////////////////////////////////////////////////////////////

	wasm_instance: null,
	utf8_decoder: new TextDecoder("utf-8"),

	platform_desc: null,

	canvas: null,
	adapter: null,
	context: null,
	presentation_format: null,

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// INTEROP OBJECTS
	////////////////////////////////////////////////////////////////////////////////////////////////////

	temps: [null],
	//temps_srcs: null,
	temps_srcs: [null],

	// platform objects
	file_fetch_states: {},
	files_changed_path_hashes: [],

	// input
	inputs: [],
	mouse_x: 0,
	mouse_y: 0,

	// gpu objects
	device: null,
	gpu_buffers: [null],
	gpu_textures: [null],
	gpu_texture_views: [null],
	gpu_samplers: [null],
	gpu_pipelines: [null],
	gpu_bind_groups: [null],
	gpu_computes: [null],

	gpu_pipeline_layouts: {},
	gpu_bind_group_layouts: {},
	gpu_cmds: [null],

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// WASM API
	////////////////////////////////////////////////////////////////////////////////////////////////////

	api: {
		////////////////////////////////////////////////////////////////////////////////////////////////////
		// UTILS
		////////////////////////////////////////////////////////////////////////////////////////////////////
		wasm_on_assert_failed(srcloc_ptr, srcloc_len, invariant_ptr, invariant_len) {
			const srcloc = wasm_string(srcloc_ptr, srcloc_len);
			const invariant = wasm_string(invariant_ptr, invariant_len);
			console.error("[ASSERT FAILED]", srcloc, ":", invariant);
		},

		wasm_console_log(message_ptr, message_len) { console.log(wasm_string(message_ptr, message_len)); },
		wasm_console_error(message_ptr, message_len) { console.error(wasm_string(message_ptr, message_len)); },
		wasm_console_log_temp(temp_obj) { console.log(STATE.temps[temp_obj]); },

		wasm_document_set_title(title_ptr, title_len) { document.title = wasm_string(title_ptr, title_len); },

		wasm_parse_float(ptr, len) { return parseFloat(wasm_string(ptr, len)) || 0.0; },

		////////////////////////////////////////////////////////////////////////////////////////////////////
		// MATH
		////////////////////////////////////////////////////////////////////////////////////////////////////
		exp(f) { return Math.exp(f); },
		log(f) { return Math.log(f); },
		pow(base, exponent) { return Math.pow(base, exponent); },
		sin(rad) { return Math.sin(rad); },
		cos(rad) { return Math.cos(rad); },
		tan(rad) { return Math.tan(rad); },
		asin(f) { return Math.asin(f); },
		acos(f) { return Math.acos(f); },
		atan2(y, x) { return Math.atan2(y, x); },

		////////////////////////////////////////////////////////////////////////////////////////////////////
		// TEMPS
		////////////////////////////////////////////////////////////////////////////////////////////////////
		wasm_pop_temps_to(index) {
			if (index > 0) {
				ASSERT(index < STATE.temps.length);
				STATE.temps.length = index;

				if (STATE.temps_srcs) {
					STATE.temps_srcs.length = index;
				}
			}
		},
		wasm_temps_assert_empty(ctx_label_ptr, ctx_label_len) { assert_temps_empty(wasm_string(ctx_label_ptr, ctx_label_len)); },
		wasm_push_temp_obj() { return push_temp({}); },
		wasm_push_temp_array() { return push_temp([]); },
		wasm_push_temp_string(ptr, len) { return push_temp(wasm_string(ptr, len)); },
		wasm_temp_obj_set_bool(obj_index, key_ptr, key_len, b) {
			const key = wasm_string(key_ptr, key_len);
			STATE.temps[obj_index][key] = b;
		},
		wasm_temp_obj_set_int(obj_index, key_ptr, key_len, i) {
			const key = wasm_string(key_ptr, key_len);
			STATE.temps[obj_index][key] = i;
		},
		wasm_temp_obj_set_float(obj_index, key_ptr, key_len, f) {
			const key = wasm_string(key_ptr, key_len);
			STATE.temps[obj_index][key] = f;
		},
		wasm_temp_obj_set_ptr(obj_index, key_ptr, key_len, p) {
			const key = wasm_string(key_ptr, key_len);
			STATE.temps[obj_index][key] = p;
		},
		wasm_temp_obj_set_temp(obj_index, key_ptr, key_len, value_index) {
			const key = wasm_string(key_ptr, key_len);
			const value = STATE.temps[value_index];
			STATE.temps[obj_index][key] = value;
		},
		wasm_temp_array_push_bool(array_index, b) { STATE.temps[array_index].push(b); },
		wasm_temp_array_push_int(array_index, i) { STATE.temps[array_index].push(i); },
		wasm_temp_array_push_float(array_index, f) { STATE.temps[array_index].push(f); },
		wasm_temp_array_push_ptr(array_index, p) { STATE.temps[array_index].push(p); },
		wasm_temp_array_push_temp(array_index, value_index) {
			const value = STATE.temps[value_index];
			STATE.temps[array_index].push(value);
		},

		////////////////////////////////////////////////////////////////////////////////////////////////////
		// PLATFORM
		////////////////////////////////////////////////////////////////////////////////////////////////////

		wasm_file_read_all(uri_ptr, uri_len, uri_hash, arena) {
			let uri = wasm_string(uri_ptr, uri_len);
			if (IS_LOCALHOST && !uri.startsWith("/")) {
				// NOTE: make uri absolute
				uri = "/" + uri;
			}

			let result_ptr = 0;

			const fetch_state = STATE.file_fetch_states[uri];
			if (fetch_state === undefined) {
				// NOTE: file needs fetching

				const fetch_future = fetch(uri).then(r => r.arrayBuffer()).then(buf => {
					STATE.file_fetch_states[uri].buf = buf;
					STATE.files_changed_path_hashes.push(uri_hash);
				}).catch(e => {
					delete STATE.file_fetch_states[uri];
				});

				STATE.file_fetch_states[uri] = { future: fetch_future };
			} else if (fetch_state.buf) {
				// NOTE: file already fetched

				const fetched_bytes = new Uint8Array(fetch_state.buf);
				const buf_size = fetched_bytes.length;
				const buf_ptr = wasm_fns().platform_arena_alloc(arena, buf_size, /* align */ 1);
				wasm_buffer_view(buf_ptr, buf_size).set(fetched_bytes);

				result_ptr = buf_ptr;

				delete STATE.file_fetch_states[uri];
			}

			return result_ptr;
		},

		////////////////////////////////////////////////////////////////////////////////////////////////////
		// GPU
		////////////////////////////////////////////////////////////////////////////////////////////////////

		// push temp
		wasm_gpu_push_temp_buffer(index) { return push_temp(STATE.gpu_buffers[index]); },
		wasm_gpu_push_temp_texture(index) { return push_temp(STATE.gpu_textures[index]); },
		wasm_gpu_push_temp_texture_view(index) { return push_temp(STATE.gpu_texture_views[index]); },
		wasm_gpu_push_temp_sampler(index) { return push_temp(STATE.gpu_samplers[index]); },

		wasm_gpu_push_temp_pipeline_layout(hash) { return push_temp(STATE.gpu_pipeline_layouts[hash]); },
		wasm_gpu_push_temp_bind_group_layout(hash) { return push_temp(STATE.gpu_bind_group_layouts[hash]); },

		wasm_gpu_device_query_limit(name_ptr, name_len) {
			const name = wasm_string(name_ptr, name_len);
			const result = STATE.device.limits[name] | 0;
			return result;
		},

		// create
		wasm_gpu_buffer_create(desc_index) {
			const desc = STATE.temps[desc_index];
			if (desc.init_data) {
				desc.mappedAtCreation = true;
			}

			const buffer = STATE.device.createBuffer(desc);

			if (desc.init_data) {
				const init_data = wasm_buffer_view(desc.init_data, desc.size);
				const mapped = buffer.getMappedRange(/* offset */ 0, /* size */ buffer.size);
				new Uint8Array(mapped).set(init_data);
				buffer.unmap();
			}

			return pool_alloc(STATE.gpu_buffers, buffer);
		},
		wasm_gpu_texture_create(desc_index) {
			const texture = STATE.device.createTexture(STATE.temps[desc_index]);
			return pool_alloc(STATE.gpu_textures, texture);
		},
		wasm_gpu_texture_view_create(texture_index, desc_index) {
			const texture = STATE.gpu_textures[texture_index];
			const texture_view = texture.createView(STATE.temps[desc_index]);
			return pool_alloc(STATE.gpu_texture_views, texture_view);
		},
		wasm_gpu_sampler_create(desc_index) {
			const sampler = STATE.device.createSampler(STATE.temps[desc_index]);
			return pool_alloc(STATE.gpu_samplers, sampler);
		},
		wasm_gpu_pipeline_create(desc_index) {
			function compile_module(desc) {
				const result = STATE.device.createShaderModule(desc);
				result.getCompilationInfo().then((info) => {
					if (info.messages.length > 0) {
						console.error(`shader compilation errors (${info.messages.length}):`, desc.label);
						for (const message of info.messages) {
							console.error("*", message.message, ":", message.lineNum, ":", message.offset);
						}
					}
				});
				return result;
			}

			const desc = STATE.temps[desc_index];

			if (desc.vertex) {
				desc.vertex.module = compile_module({
					code: wasm_string(desc.vertex.code_ptr, desc.vertex.code_len),
					compilationHints: [{entryPoint: desc.vertex.entryPoint}],
					label: desc.label + ".vs",
				});
			}

			if (desc.fragment) {
				desc.fragment.module = compile_module({
					code: wasm_string(desc.fragment.code_ptr, desc.fragment.code_len),
					compilationHints: [{entryPoint: desc.fragment.entryPoint}],
					label: desc.label + ".ps",
				});

				for (const target of desc.fragment.targets) {
					target.format = target.format ?? STATE.presentation_format;
				}
			}

			const pipeline = STATE.device.createRenderPipeline(desc);
			return pool_alloc(STATE.gpu_pipelines, pipeline);
		},
		wasm_gpu_bind_group_create(desc_index) {
			const bind_group = STATE.device.createBindGroup(STATE.temps[desc_index]);
			return pool_alloc(STATE.gpu_bind_groups, bind_group);
		},
		wasm_gpu_compute_create(desc_index) {
			const compute = STATE.device.createComputePipeline(STATE.temps[desc_index]);
			return pool_alloc(STATE.gpu_computes, compute);
		},

		wasm_gpu_pipeline_layout_create(hash, desc_index) {
			const desc = STATE.temps[desc_index];

			const bind_group_layout_labels = desc.bindGroupLayouts.map((bgl) => JSON.parse(bgl.label));
			desc.label = JSON.stringify({ bindGroupLayouts: bind_group_layout_labels });

			const pipeline_layout = STATE.device.createPipelineLayout(desc);
			STATE.gpu_pipeline_layouts[hash] = pipeline_layout;
		},
		wasm_gpu_bind_group_layout_create(hash, desc_index) {
			const desc = STATE.temps[desc_index];
			desc.label = JSON.stringify(desc);
			const bind_group_layout = STATE.device.createBindGroupLayout(desc);
			STATE.gpu_bind_group_layouts[hash] = bind_group_layout;
		},

		// destroy
		wasm_gpu_buffer_destroy(index) { STATE.gpu_buffers[index].destroy(); STATE.gpu_buffers[index] = null; },
		wasm_gpu_texture_destroy(index) { STATE.gpu_textures[index].destroy(); STATE.gpu_textures[index] = null; },
		wasm_gpu_texture_view_destroy(index) { STATE.gpu_texture_views[index] = null; },
		wasm_gpu_sampler_destroy(index) { STATE.gpu_samplers[index] = null; },
		wasm_gpu_pipeline_destroy(index) { STATE.gpu_pipelines[index] = null; },
		wasm_gpu_bind_group_destroy(index) { STATE.gpu_bind_groups[index] = null; },
		wasm_gpu_compute_destroy(index) { STATE.gpu_computes[index] = null; },

		// read/write resources
		wasm_gpu_buffer_read(index, ptr, size) {
			// TODO: do we really need read back?
			ASSERT(false);
		},
		wasm_gpu_buffer_write(index, ptr, size) {
			const buffer = STATE.gpu_buffers[index];
			const data = wasm_buffer_view(ptr, size);
			STATE.device.queue.writeBuffer(buffer, /* bufferOffset */ 0, data, /* dataOffset */ 0, size);
		},
		wasm_gpu_texture_read(index, slice, mip, ptr, size) {
			// TODO: do we really need read back?
			ASSERT(false);
		},
		wasm_gpu_texture_write(index, slice, mip, width, height, slices_len, ptr, size, bytes_per_row) {
			const texture = STATE.gpu_textures[index];
			const dst = {
				mipLevel: mip,
				origin: { z: slice },
				texture: texture,
			};
			const data = wasm_buffer_view(ptr, size);
			const data_layout = {
				bytesPerRow: bytes_per_row,
			};
			const write_size = [width, height, slices_len];
			STATE.device.queue.writeTexture(dst, data, data_layout, write_size);
		},

		// command buffer
		wasm_gpu_command_buffer_begin(desc_index) {
			const cmds = {
				encoder: STATE.device.createCommandEncoder(STATE.temps[desc_index]),
				pass_encoder: null,
				compute_encoder: null,
			};
			return pool_alloc(STATE.gpu_cmds, cmds);
		},
		wasm_gpu_command_buffer_submit(cmds_indices_array_index) {
			const cmds_indices = STATE.temps[cmds_indices_array_index];
			const cmds_bufs = cmds_indices.map((index) => STATE.gpu_cmds[index].encoder.finish());
			STATE.device.queue.submit(cmds_bufs);
			for (const index of cmds_indices) {
				STATE.gpu_cmds[index] = null;
			}
		},

		// commands
		wasm_gpu_cmd_debug_group_begin(cmds_index, debug_label_ptr, debug_label_len) {
			const debug_label = wasm_string(debug_label_ptr, debug_label_len);
			const cmds = STATE.gpu_cmds[cmds_index];
			if (cmds.pass_encoder) {
				cmds.pass_encoder.pushDebugGroup(debug_label);
			} else if (cmds.compute_encoder) {
				cmds.compute_encoder.pushDebugGroup(debug_label);
			} else {
				cmds.encoder.pushDebugGroup(debug_label);
			}
		},
		wasm_gpu_cmd_debug_group_end(cmds_index) {
			const cmds = STATE.gpu_cmds[cmds_index];
			if (cmds.pass_encoder) {
				cmds.pass_encoder.popDebugGroup();
			} else if (cmds.compute_encoder) {
				cmds.compute_encoder.popDebugGroup();
			} else {
				cmds.encoder.popDebugGroup();
			}
		},
		wasm_gpu_cmd_set_viewport(cmds_index, x, y, width, height, min_depth, max_depth) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			encoder.setViewport(x, y, width, height, min_depth, max_depth);
		},
		wasm_gpu_cmd_set_scissor(cmds_index, x, y, width, height) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			encoder.setViewport(x, y, width, height);
		},
		wasm_gpu_cmd_copy_buffer(cmds_index, dst_index, src_index) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			//encoder.copyBufferToBuffer(source: GPUBuffer, sourceOffset: GPUSize64, destination: GPUBuffer, destinationOffset: GPUSize64, size: GPUSize64): void
			ASSERT(false);
		},
		wasm_gpu_cmd_copy_texture(cmds_index, dst_index, src_index) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			//encoder.copyTextureToTexture(source: GPUImageCopyTexture, destination: GPUImageCopyTexture, copySize: GPUExtent3D): void
			ASSERT(false);
		},
		wasm_gpu_cmd_generate_mip_maps(cmds_index, texture_index) {
			// TODO: implement
			ASSERT(false);
		},
		wasm_gpu_cmd_pass_begin(cmds_index, desc_index) {
			const cmds = STATE.gpu_cmds[cmds_index];
			ASSERT(cmds.pass_encoder == null);

			const desc = STATE.temps[desc_index];

			for (const attachment of desc.colorAttachments) {
				// NOTE: color attachments
				attachment.view = attachment.view ?
					attachment.view :
					STATE.context.getCurrentTexture().createView(); // swapchain
			}

			cmds.pass_encoder = cmds.encoder.beginRenderPass(desc);
		},
		wasm_gpu_cmd_pass_end(cmds_index) {
			const cmds = STATE.gpu_cmds[cmds_index];
			cmds.pass_encoder.end();
			cmds.pass_encoder = null;
		},
		wasm_gpu_cmd_bind_pipeline(cmds_index, pipeline_index, stencil_ref, blend_color) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			const pipeline = STATE.gpu_pipelines[pipeline_index];
			encoder.setPipeline(pipeline);
			encoder.setStencilReference(stencil_ref);
			encoder.setBlendConstant(new Uint32Array(wasm_memory_buffer(), blend_color, 4));
		},
		wasm_gpu_cmd_bind_vertex_buffer(cmds_index, buffer_index, slot) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			const buffer = STATE.gpu_buffers[buffer_index];
			encoder.setVertexBuffer(slot, buffer, /* offset */ 0, buffer.size);
		},
		wasm_gpu_cmd_bind_index_buffer(cmds_index, buffer_index, indexing) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			const buffer = STATE.gpu_buffers[buffer_index];
			const buffer_indexing =
				indexing == 0 ? "uint16" :
				indexing == 1 ? "uint32" :
				ASSERT(false);
			encoder.setIndexBuffer(buffer, buffer_indexing, /* offset */ 0, buffer.size);
		},
		wasm_gpu_cmd_bind_group(cmds_index, group_index, index, offsets_ptr, offsets_len) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			const bind_group = STATE.gpu_bind_groups[group_index];
			const offsets_data = new Uint32Array(wasm_memory_buffer(), offsets_ptr, offsets_len);
			encoder.setBindGroup(index, bind_group, offsets_data, /* dynamicOffsetsDataStart*/ 0, offsets_len);
		},
		wasm_gpu_cmd_draw(cmds_index, vertex_count, instance_count, first_vertex, first_instance) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			encoder.draw(vertex_count, instance_count, first_vertex, first_instance);
		},
		wasm_gpu_cmd_draw_indexed(cmds_index, index_count, instance_count, first_index, base_vertex, first_instance) {
			const encoder = STATE.gpu_cmds[cmds_index].pass_encoder;
			encoder.drawIndexed(index_count, instance_count, first_index, base_vertex, first_instance);
		},

		// TODO: implement these commands
		wasm_gpu_cmd_compute_begin(cmds_index) { ASSERT(false); },
		wasm_gpu_cmd_compute_end(cmds_index) { ASSERT(false); },
		wasm_gpu_cmd_bind_compute(cmds_index, compute_index) { ASSERT(false); },
		wasm_gpu_cmd_dispatch(cmds_index, thread_group_x, thread_group_y, thread_group_z) { ASSERT(false); },
	},
};

////////////////////////////////////////////////////////////////////////////////////////////////////
// JS API
////////////////////////////////////////////////////////////////////////////////////////////////////

export async function init({wasm_source_promise, canvas} = {}) {
	STATE.canvas = canvas ?? document.querySelector("canvas");

	const adapter = await navigator.gpu?.requestAdapter();
	STATE.device = await adapter?.requestDevice({
		requiredFeatures: [
			"depth-clip-control",
			"texture-compression-bc",
			"float32-filterable",
			"depth32float-stencil8",
		],
	});
	if (!STATE.device) {
		console.error("could not create device");
		return;
	}

	STATE.context = STATE.canvas.getContext("webgpu");
	STATE.presentation_format = navigator.gpu.getPreferredCanvasFormat();

	STATE.context.configure({
		device: STATE.device,
		format: STATE.presentation_format,
		alphaMode: "premultiplied",
	});

	const imports = { env: STATE.api };
	// TODO: do we actually need this?
	//imports.env.memory = new WebAssembly.Memory({ initial: WASM_MEMORY_PAGES_LEN, maximum: WASM_MEMORY_PAGES_LEN });

	const { instance } = await WebAssembly.instantiateStreaming(wasm_source_promise, imports);
	STATE.wasm_instance = instance;

	{
		// NOTE: wasm init

		const platform_desc = wasm_fns().platform_init();
		STATE.platform_desc = STATE.temps[platform_desc];
		STATE.api.wasm_pop_temps_to(platform_desc);

		// NOTE: prefetching
		for (const uri in STATE.file_fetch_states) {
			const fetch_state = STATE.file_fetch_states[uri];
			if (fetch_state.future) {
				await fetch_state.future;
			}
		}
	}

	window.onkeydown = on_key_event;
	window.onkeyup = on_key_event;
	window.onmousedown = on_mouse_down;
	window.onmouseup = on_mouse_up;
	window.onmousemove = on_mouse_move;

	on_animation_frame();

	// NOTE: for easier late inspection
	window.nanquim_state = STATE;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// MAIN LOOP
////////////////////////////////////////////////////////////////////////////////////////////////////


const EVENT_CODE_TO_INPUT_KIND_NAME = {
	Escape: "PLATFORM_INPUT_KEY_ESC",
	ArrowDown: "PLATFORM_INPUT_KEY_DOWN",
	ArrowUp: "PLATFORM_INPUT_KEY_UP",
	ArrowLeft: "PLATFORM_INPUT_KEY_LEFT",
	ArrowRight: "PLATFORM_INPUT_KEY_RIGHT",
	Home: "PLATFORM_INPUT_KEY_HOME",
	End: "PLATFORM_INPUT_KEY_END",
	PageDown: "PLATFORM_INPUT_KEY_PAGEDOWN",
	PageUp: "PLATFORM_INPUT_KEY_PAGEUP",
	Backspace: "PLATFORM_INPUT_KEY_BACKSPACE",
	Delete: "PLATFORM_INPUT_KEY_DELETE",
	Tab: "PLATFORM_INPUT_KEY_CHAR",
	Space: "PLATFORM_INPUT_KEY_CHAR",
	Enter: "PLATFORM_INPUT_KEY_CHAR",
	ShiftLeft: "PLATFORM_INPUT_KEY_SHIFT",
	ShiftRight: "PLATFORM_INPUT_KEY_SHIFT",
	ControlLeft: "PLATFORM_INPUT_KEY_CONTROL",
	ControlRight: "PLATFORM_INPUT_KEY_CONTROL",
	AltLeft: "PLATFORM_INPUT_KEY_ALT",
	AltRight: "PLATFORM_INPUT_KEY_ALT",
};
const EVENT_CODE_TO_INPUT_VALUE = {
	Tab: "\t".codePointAt(0),
	Space: " ".codePointAt(0),
	Enter: "\n".codePointAt(0),
	ShiftLeft: 0,
	ShiftRight: 1,
	ControlLeft: 0,
	ControlRight: 1,
	AltLeft: 0,
	AltRight: 1,
};
const EVENT_TYPE_TO_DOWN = {
	keydown: true,
	keyup: false,
};

function on_key_event(event) {
	if (!event.repeat) {
		const event_code = event.code;

		let kind_name = EVENT_CODE_TO_INPUT_KIND_NAME[event_code];
		let value = EVENT_CODE_TO_INPUT_VALUE[event_code];

		if (kind_name == null) {
			if (event_code.startsWith("Key")) {
				kind_name = "PLATFORM_INPUT_KEY_CHAR";
				value = event.key.codePointAt(0);
			} else if (event_code.startsWith("F")) {
				// TODO: implement Fn input keys
				ASSERT(false);
			}
		}

		const down = EVENT_TYPE_TO_DOWN[event.type];

		if (kind_name && down != null) {
			STATE.inputs.push({
				kind: input_kind_from_name(kind_name),
				value,
				down,
			});
		}
	}
}

function on_mouse_down(event) {
	push_mouse_button("PLATFORM_INPUT_MOUSE_LEFT", /* down */ true);
}

function on_mouse_up(event) {
	push_mouse_button("PLATFORM_INPUT_MOUSE_LEFT", /* down */ false);
}

function on_mouse_move(event) {
	STATE.mouse_x = event.x;
	STATE.mouse_y = event.y;
}

function on_animation_frame() {
	const fns = wasm_fns();

	{
		// NOTE: debug checks

		assert_temps_empty("on_animation_frame");
		for (const cmds of STATE.gpu_cmds) {
			ASSERT(cmds == null);
		}
	}

	{
		// NOTE: check canvas size

		const device_pixel_ratio = window.devicePixelRatio;
		const target_width = STATE.canvas.clientWidth * device_pixel_ratio;
		const target_height = STATE.canvas.clientHeight * device_pixel_ratio;

		if (target_width != STATE.canvas.width || target_height != STATE.canvas.height) {
			STATE.canvas.width = target_width;
			STATE.canvas.height = target_height;

			fns.platform_resize(STATE.canvas.width, STATE.canvas.height);
		}
	}

	{
		// NOTE: notify completed file reads

		const files_changed_path_hashes = STATE.files_changed_path_hashes.splice(0, STATE.platform_desc.files_changed_cap);
		const ptr = fns.platform_alloc_files_changed_path_hashes(files_changed_path_hashes.length);
		const hashes = new BigUint64Array(wasm_memory_buffer(), ptr, files_changed_path_hashes.length);

		let index = 0;
		for (const path_hash of files_changed_path_hashes) {
			hashes[index] = path_hash;
			index += 1;
		}
	}

	{
		// NOTE: input

		fns.platform_input_mouse_pos(STATE.mouse_x, STATE.mouse_y);
		const inputs = STATE.inputs.splice(0, STATE.platform_desc.inputs_cap);
		for (const input of inputs) {
			fns.platform_input_push(input.kind, input.value, input.down);
		}
	}

	fns.platform_on_animation_frame();
	requestAnimationFrame(on_animation_frame);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// UTILS
////////////////////////////////////////////////////////////////////////////////////////////////////

function ASSERT(invariant) { if (!invariant) { throw "assert failed"; } }

function wasm_fns() { return STATE.wasm_instance.exports; }
function wasm_memory_buffer() { return wasm_fns().memory.buffer; }
function wasm_buffer_view(ptr, size) { return new Uint8Array(wasm_memory_buffer(), ptr, size); }
function wasm_string(ptr, len) { return STATE.utf8_decoder.decode(wasm_buffer_view(ptr, len)); }

function assert_temps_empty(ctx_label) {
	ASSERT(STATE.temps[0] == null);

	if (STATE.temps.length != 1) {
		if (STATE.temps_srcs) {
			console.error("unpopped temps objects:", STATE.temps.length - 1, "at", ctx_label);
			let temp_i = 0;
			for (const stack of STATE.temps_srcs) {
				if (stack) {
					console.log("temp", temp_i - 1, ":", stack);
				}
				temp_i += 1;
			}
		}

		ASSERT(false);
	}
}

function push_temp(obj) {
	let result = 0;
	if (obj != null) {
		result = STATE.temps.push(obj) - 1;

		if (STATE.temps_srcs) {
			STATE.temps_srcs.push(new Error().stack);
		}
	}

	return result;
}

function pool_alloc(pool, obj) {
	// NOTE: index zero is always reserved for null
	ASSERT(pool[0] == null);
	let index = pool.indexOf(null, 1);
	if (index >= 0) {
		pool[index] = obj;
	} else {
		index = pool.push(obj) - 1;
	}
	return index;
}

function input_kind_from_name(name) {
	const result = STATE.platform_desc.input_kinds[name];
	ASSERT(result);
	return result;
}

function push_mouse_button(kind_name, down) {
	STATE.inputs.push({
		kind: input_kind_from_name(kind_name),
		down,
	});
}
