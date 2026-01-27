import glfw3.api;
import bindbc.opengl.util;
import bindbc.opengl;
import asset;
import std.concurrency;
import std.stdio;

class Mesh
{
	float[] points =
		[
			-0.5, -0.5, 0.5,
			-0.5, 0.5, 0.5,
			0.5, 0.5, 0.5,
			0.5, -0.5, 0.5,
	];

	GLuint vbo = 0;
	GLuint vao = 0;

	const char* vertex_shader =
		"#version 410 core
		in vec3 vp;
		void main() {
			gl_Position = vec4( vp, 1.0 );
		}";

	const char* fragment_shader =
		"#version 410 core
		out vec4 frag_color;
		void main() {
			frag_color = vec4( 0.5, 0.5, 0.0, 1.0 )
		};";

	GLuint shader = 0;

	void Init()
	{
		glGenBuffers(1, &vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, 12 * float.sizeof, points.ptr, GL_STATIC_DRAW);
		glGenVertexArrays(1, &vao);
		glBindVertexArray(vao);
		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, null);

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

extern(C) @nogc nothrow void mouse_button_callback(GLFWwindow* window, int button, int action, int mods)
{
	double dxpos, dypos;
	glfwGetCursorPos(window, &dxpos, &dypos);
	mouse_x = cast(int)dxpos;
	mouse_y = cast(int)dypos;
	mouse_button = button;
	mouse_action = action;
	mouse_pending = true;
}

bool key_pending = false;
uint key_chr = 0;

extern(C) @nogc nothrow void text_callback(GLFWwindow* window, uint chr)
{
	key_pending = true;
	key_chr = chr;
}

extern(C) @nogc nothrow void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods)
{
	if(key >= 256 && action == GLFW_PRESS)
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

	Mesh[] meshes = [new Mesh];
	foreach (mesh; meshes)
	{
		mesh.Init();
	}

	while (!glfwWindowShouldClose(window) && Render_run)
	{
		glfwPollEvents();

		if(mouse_pending)
		{
			mouse_pending = false;
		}

		if(key_pending)
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

		foreach (mesh; meshes)
		{
			glUseProgram(mesh.shader);
			glBindVertexArray(mesh.vao);

			glDrawArrays(GL_TRIANGLES, 0, 4);
		}

		glfwSwapBuffers(window);

	}

	glfwTerminate();
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
