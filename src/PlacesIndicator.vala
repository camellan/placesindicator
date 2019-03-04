// valac -X -D'GETTEXT_PACKAGE="com.github.camellan.placesindicator"' --pkg gtk+-3.0 --pkg appindicator3-0.1 --pkg glib-2.0 PlacesIndicator.vala

using GLib;
using Gtk;
using AppIndicator;

public class IndicatorPlaces : GLib.Object {

    private static string user_home;
    private static string config_dir;
    private static string filename;
    private static string icon_name;
    private static string path;
    private static string label;

    private static GLib.File file;
    private static Gtk.Menu menu;
    private static Gtk.Image icon;
    private static Gtk.ImageMenuItem home;
    private static Gtk.ImageMenuItem root;
    private static Gtk.ImageMenuItem recent;
    private static Gtk.ImageMenuItem net;
    private static Gtk.ImageMenuItem trash;
    private static Gtk.ImageMenuItem quit;
    private static Gtk.ImageMenuItem item;
    private static Gtk.SeparatorMenuItem sep;
    protected static Indicator indicator;
    protected static FileMonitor monitor;

    public static void make_std_places () {
        home = new Gtk.ImageMenuItem.with_label (_("Home Folder"));
        icon = new Gtk.Image.from_icon_name ("folder-home", Gtk.IconSize.MENU);
        home.set_always_show_image (true);
        home.set_image (icon);
        menu.append (home);
        home.activate.connect (() => {
            try{
                GLib.AppInfo.launch_default_for_uri ("file:" + user_home, null);
            }
            catch (GLib.Error error) {
                warning ("Error opening home directory: %s", error.message);
            }
        });

        root = new Gtk.ImageMenuItem.with_label (_("Root"));
        icon = new Gtk.Image.from_icon_name ("computer", Gtk.IconSize.MENU);
        root.set_always_show_image (true);
        root.set_image (icon);
        menu.append (root);
        root.activate.connect (() => {
            try{
                GLib.AppInfo.launch_default_for_uri ("file:///", null);
            }
            catch (GLib.Error error) {
                warning ("Error opening root directory: %s", error.message);
            }
        });

        recent = new Gtk.ImageMenuItem.with_label (_("Recent"));
        icon = new Gtk.Image.from_icon_name ("document-open-recent", Gtk.IconSize.MENU);
        recent.set_always_show_image (true);
        recent.set_image (icon);
        menu.append (recent);
        recent.activate.connect (() => {
            try{
                GLib.AppInfo.launch_default_for_uri ("recent:///", null);
            }
            catch (GLib.Error error) {
                warning ("Error opening recent directory: %s", error.message);
            }
        });

        net = new Gtk.ImageMenuItem.with_label (_("Network"));
        icon = new Gtk.Image.from_icon_name ("folder-network", Gtk.IconSize.MENU);
        net.set_always_show_image (true);
        net.set_image (icon);
        menu.append (net);
        net.activate.connect (() => {
            try{
                GLib.AppInfo.launch_default_for_uri ("network:///", null);
            }
            catch (GLib.Error error) {
                warning ("Error opening network directory: %s", error.message);
            }
        });

        trash = new Gtk.ImageMenuItem.with_label (_("Trash"));
        icon = new Gtk.Image.from_icon_name ("user-trash", Gtk.IconSize.MENU);
        trash.set_always_show_image (true);
        trash.set_image (icon);
        menu.append (trash);
        trash.activate.connect (() => {
            try{
                GLib.AppInfo.launch_default_for_uri ("trash:///", null);
            }
            catch (GLib.Error error) {
                warning ("Error opening trash: %s", error.message);
            }
        });

        sep = new Gtk.SeparatorMenuItem();
        menu.append (sep);
    }

    public static void make_user_places () {
        user_home = GLib.Environment.get_home_dir ();
        config_dir = GLib.Path.build_filename (user_home, ".config");
        filename = GLib.Path.build_filename (config_dir, "gtk-3.0", "bookmarks", null);
        file = GLib.File.new_for_path (filename);

        if (!file.query_exists ()) {
            stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
        }

        try {
            var dis = new DataInputStream (file.read ());
            string line;

            while ((line = dis.read_line (null)) != null) {
            	path = line.split (" ")[0];
				label = line.split (" ")[1];
				item = new Gtk.ImageMenuItem.with_label (label);
				get_user_icon (path);
				item.set_always_show_image (true);
				icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.MENU);
				item.set_image (icon);
				menu.append(item);
                item.activate.connect (() => {
                    try{
                        GLib.AppInfo.launch_default_for_uri (path, null);
                        print (path + "\n" + label + "\n");
                    }
                    catch (GLib.Error error) {
                        warning ("Error opening directory: %s", error.message);
                    }
                });
            }
        }
        catch (GLib.Error error) {
            warning ("%s", error.message);
        }
        sep = new Gtk.SeparatorMenuItem ();
       	menu.append (sep);
    }

    public static void get_user_icon ( string path) {
        if (path[0:3] == "smb" || path[0:3] == "ssh" || path[0:3] == "ftp" || path[0:3] == "net" || path[0:3] == "dav") {
            icon_name = "folder-remote";
        }
        else {
            icon_name = "folder";
        }
    }

    public static void make_quit () {
        quit = new Gtk.ImageMenuItem.with_label(_("Quit"));
        icon = new Gtk.Image.from_icon_name ("application-exit", Gtk.IconSize.MENU);
        quit.set_always_show_image(true);
        quit.set_image(icon);
        quit.activate.connect(() => {
            Gtk.main_quit();
        });
        menu.append (quit);
    }

    public static void make_menu () {
    	menu = new Gtk.Menu();
		make_std_places ();
        make_user_places ();
        make_quit ();
        menu.show_all ();
        indicator.set_menu (menu);
    }

    public static void start_monitor () {
        try {
            monitor = file.monitor (FileMonitorFlags.NONE, null);
            print ("Monitoring: %s\n", file.get_path ());
            monitor.changed.connect ((src, dest, event) => {
                if (event.to_string () == "G_FILE_MONITOR_EVENT_CHANGES_DONE_HINT") {
                    print("Bookmarks changed, updating menu...\n");
                    make_menu ();
                }
            });
        }
        catch (Error err) {
            print ("Error: %s\n", err.message);
        }
    }

	public static int main(string[] args) {

		Gtk.init(ref args);
		indicator = new Indicator("places", "system-file-manager",
				                      IndicatorCategory.APPLICATION_STATUS);
		if (!(indicator is Indicator)) return -1;
		indicator.set_status(IndicatorStatus.ACTIVE);
		make_menu ();
		start_monitor ();
		Gtk.main ();
		return 0;
	}
}