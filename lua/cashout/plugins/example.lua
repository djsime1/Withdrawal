print("Loaded example plugin")
concommand.Add("plugin_example", function() Derma_Message("Hello world!", "Example plugin", "Close") end)