import glfw3.api;
import bindbc.opengl.util;
import bindbc.opengl;
import asset;
import std.concurrency;
import std.stdio;
import math;
import app;

struct Camera
{
	Transform3D transform;
	
	const float near = 0.2;
	const float far = 9000;
	const float top = 1*0.25f;
	const float right = 1.77777*0.25f;
	const float left = -1.77777*0.25f;
	const float bottom = -1*0.25f;
	
	const float4x4 projmat = cast(float4x4)[
		2*near/(right-left),0,0,0,
		0,2*near/(top-bottom),0,0,
		(right+left)/(right-left),(top+bottom)/(top-bottom),-(far+near)/(far-near),-1,
		0,0,-2*(far*near)/(far-near),0
	];
	
	alias this = transform;

	void SetPosition(float3 position)
	{
		transform.position = float3([0,0,0]) - position;
	}
}

struct Model
{
	Transform3D transform;

	float[] points =
		[
			0.5, 0.5, 0.0,
			-0.5, 0.5, 0.0,
			-0.5, -0.5, 0.0,
			0.5, -0.5, 0.0,
			-0.5, -0.5, 0.0,
			0.5, 0.5, 0.0,
	];

	GLuint vbo = 0;
	GLuint vao = 0;

	const char* vertex_shader =
		"#version 460 core
		layout(location = 0) in vec3 vp;
		uniform mat4 view_matrix;
		uniform mat4 proj_matrix;
		uniform mat4 model_matrix;

		void main() {
			gl_Position = proj_matrix * view_matrix * model_matrix * vec4( vp, 1.0 );
		}";

	const char* fragment_shader =
		"#version 460 core
		layout(location = 0) out vec4 frag_color;
		void main() {
			frag_color = vec4( 0.5, 0.5, 0.0, 1.0 );
		}";

	GLuint shader = 0;

	void Init()
	{
		glGenBuffers(1, &vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, points.length * float.sizeof, points.ptr, GL_STATIC_DRAW);
		glGenVertexArrays(1, &vao);
		glBindVertexArray(vao);
		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);

		GLuint v_shader = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(v_shader, 1, &vertex_shader, null);
		glCompileShader(v_shader);
		
		
		GLuint f_shader = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(f_shader, 1, &fragment_shader, null);
		glCompileShader(f_shader);

		

		shader = glCreateProgram();
		glAttachShader(shader, v_shader);
		glAttachShader(shader, f_shader);
		glLinkProgram(shader);

		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	void Render(Camera camera)
	{
		float4x4 viewmat = cast(float4x4)camera;
		float4x4 modelmat = cast(float4x4)transform;
		glUseProgram(shader);

		GLint view = glGetUniformLocation(shader, "view_matrix");
		glUniformMatrix4fv(view, 1, GL_FALSE, viewmat.ptr);
		GLint proj = glGetUniformLocation(shader, "proj_matrix");
		glUniformMatrix4fv(proj, 1, GL_FALSE, camera.projmat.ptr);
		GLint model = glGetUniformLocation(shader, "model_matrix");
		glUniformMatrix4fv(model, 1, GL_FALSE, modelmat.ptr);
		
		glBindVertexArray(vao);

		glDrawArrays(GL_TRIANGLES, 0, 6);
	}
}

extern (C) @nogc nothrow void errorCallback(int error, const(char)* description)
{
	import core.stdc.stdio;

	fprintf(stderr, "Error: %s\n", description);
}

bool mouse_pending = false;
int mouse_button = 0;
int mouse_action = 0;
int mouse_x = 0;
int mouse_y = 0;

extern (C) @nogc nothrow void mouse_button_callback(GLFWwindow* window, int button, int action, int mods)
{
	double dxpos, dypos;
	glfwGetCursorPos(window, &dxpos, &dypos);
	mouse_x = cast(int) dxpos;
	mouse_y = cast(int) dypos;
	mouse_button = button;
	mouse_action = action;
	mouse_pending = true;
}

bool key_pending = false;
uint key_chr = 0;

extern (C) @nogc nothrow void text_callback(GLFWwindow* window, uint chr)
{
	key_pending = true;
	key_chr = chr;
}

extern (C) @nogc nothrow void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods)
{
	if (key >= 256 && action == GLFW_PRESS)
	{
		key_pending = true;
		key_chr = -key;
	}
}

shared(bool) Render_run;

void Render_Loop()
{
	glfwSetErrorCallback(&errorCallback);
	glfwInit();

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);

	glfwWindowHint(GLFW_TRANSPARENT_FRAMEBUFFER, 1);
	glfwWindowHint(GLFW_DECORATED, 1);
	GLFWwindow* window = glfwCreateWindow(1280, 720, "App", null, null);
	glfwSetMouseButtonCallback(window, &mouse_button_callback);
	glfwSetCharCallback(window, &text_callback);
	glfwSetKeyCallback(window, &key_callback);

	glfwMakeContextCurrent(window);

	glfwSwapInterval(1);
	loadOpenGL();

	Camera camera = Camera(Transform3D());

	camera.SetPosition(float3([-0.5, 0.0, 0.5]));

	Model[] models = [Model()];
	foreach (ref model; models)
	{
		model.Init();
	}
	int testtime = 0;
	import std.math;
	while (!glfwWindowShouldClose(window) && Render_run)
	{
		glfwPollEvents();

		if (mouse_pending)
		{
			mouse_pending = false;
		}

		if (key_pending)
		{
			key_pending = false;
		}

		int width, height;

		glEnable(GL_BLEND);
		glfwGetFramebufferSize(window, &width, &height);
		glViewport(0, 0, width, height);
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE);
		camera.SetPosition(float3([sin(testtime*0.02f), 0.0, cos(testtime*0.026f)+1.5f]));
		testtime++;
		
		foreach (ref model; models)
		{
			model.Render(camera);
		}
		
		

		glfwSwapBuffers(window);

	}

	Kill_Everything_And_Quit();
	Render_run = false;
}

// called in main
public void Render_Init()
{
	Render_run = true;
	spawn(&Render_Loop);
}

public void Render_End()
{
	Render_run = false;
}
