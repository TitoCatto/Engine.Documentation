module settings;

struct Settings {
    float volume = 100.0f
    float mouse_sens = 100.0f
    uint fov = 120;
    // Add more settings here and remember to use them where needed
};

__gshared Settings g_settings;