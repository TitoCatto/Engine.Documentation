import std.file;
import std.path;
import std.stdio;
import glfw3.api;
import dgui;
import bindbc.opengl.util;
import server;
import client;
import sex;

extern(C) @nogc nothrow void errorCallback(int error, const(char)* description) {
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
    if (key >= 256 && action == GLFW_PRESS)
	{
		key_pending = true;
        key_chr = -key;
	}
}

Server sv;
Client cl;

void main(string[] args)
{
	glfwSetErrorCallback(&errorCallback);
	glfwInit();
	
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
	
	glfwWindowHint(GLFW_TRANSPARENT_FRAMEBUFFER, 1);
	glfwWindowHint(GLFW_DECORATED, 1);
	window = glfwCreateWindow(1280, 720, "App", null, null);
	glfwSetMouseButtonCallback(window, &mouse_button_callback);
	glfwSetCharCallback(window, &text_callback);
	glfwSetKeyCallback(window, &key_callback);
	
	glfwMakeContextCurrent(window);
	
	glfwSwapInterval(1);
	loadOpenGL();
	loadExtendedGLSymbol(cast(void**)&glBitmap, "glBitmap");
	if(glBitmap == null)
	{
		loadBaseGLSymbol(cast(void**)&glBitmap, "glBitmap");
	}
	if(glBitmap == null)
	{
		writeln("couldnt find glBitmap in your system.");
	}
	
	while (!glfwWindowShouldClose(window))
	{
		glfwPollEvents();
		
		if(mouse_pending)
		{
			DGUI_HandleMouse(mouse_x,mouse_y,mouse_button,mouse_action);
			mouse_pending = false;
		}
		
		if(key_pending)
		{
			DGUI_HandleKey(key_chr);
			key_pending = false;
		}
		
		
		int width, height;
		
		glEnable(GL_BLEND);
		glfwGetFramebufferSize(window, &width, &height);
		glViewport(0, 0, width, height);
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		glClear(GL_COLOR_BUFFER_BIT);
		glBlendFuncSeparate(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA,GL_ONE,GL_ONE);
		
		
		if(sv !is null)
		{
			sv.Tick(0.01666);
		}
		
		if(cl !is null)
		{
			cl.Tick();
		}
		glfwSwapBuffers(window);
		
	}
	glfwTerminate();
}
