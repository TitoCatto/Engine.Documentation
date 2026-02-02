import std.file;
import std.path;
import std.stdio;
import glfw3.api;
import dgui;
import server;
import client;
import sex;
import render;

void Kill_Everything_And_Quit()
{
	Render_End();
	Client_End();
	Server_End();
}

void main(string[] args)
{
	Render_Init();
	Server_Init();
	Client_Init();
	
}
