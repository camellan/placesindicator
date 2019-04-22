// valac -X -D'GETTEXT_PACKAGE="com.github.camellan.placesindicator"' --pkg gtk+-3.0 --pkg appindicator3-0.1 --pkg glib-2.0 PlacesIndicator.vala

using GLib;
using Gtk;
using AppIndicator;

public class IndicatorPlaces : GLib.Object {

    private static string user_home;
    private static string config_dir;
    private static string filename;
    private static GLib.File file;
    private static Gtk.Menu menu;
    private static Gtk.Image icon;
    private static Gtk.ImageMenuItem item;
    private static Gtk.SeparatorMenuItem sep;
    protected static Indicator indicator;
    protected static FileMonitor monitor;

    public static void make_std_places () {
        item = new Gtk.ImageMenuItem.with_label (_("Home Folder"));
        icon = new Gtk.Image.from_icon_name ("folder-home", Gtk.IconSize.MENU);
        item.set_always_show_image (true);
        item.set_image (icon);
        menu.append (item);
        item.activate.connect (() => {
            try{
                GLib.AppInfo.launch_default_for_uri ("file:" + user_home, null);
            }
            catch (GLib.Error error) {
                warning ("Error opening home directory: %s", error.message);
            }
        });

        item = new Gtk.ImageMenuItem.with_label (_("Root"));
        icon = new Gtk.Image.from_icon_name ("computer", Gtk.IconSize.MENU);
        item.set_always_show_image (true);
        item.set_image (icon);
        menu.append (item);
        item.activate.connect (() => {
            try{
                GLib.AppInfo.launch_default_for_uri ("file:///", null);
            }
            catch (GLib.Error error) {
                warning ("Error opening root directory: %s", error.message);
            }
        });

        item = new Gtk.ImageMenuItem.with_label (_("Recent"));
        icon = new Gtk.Image.from_icon_name ("document-open-recent", Gtk.IconSize.MENU);
        item.set_always_show_image (true);
        item.set_image (icon);
        menu.append (item);
        item.activate.connect (() => {
            try{
                GLib.AppInfo.launch_default_for_uri ("recent:///", null);
            }
            catch (GLib.Error error) {
                warning ("Error opening recent directory: %s", error.message);
            }
        });

        item = new Gtk.ImageMenuItem.with_label (_("Network"));
        icon = new Gtk.Image.from_icon_name ("folder-network", Gtk.IconSize.MENU);
        item.set_always_show_image (true);
        item.set_image (icon);
        menu.append (item);
        item.activate.connect (() => {
            try{
                GLib.AppInfo.launch_default_for_uri ("network:///", null);
            }
            catch (GLib.Error error) {
                warning ("Error opening network directory: %s", error.message);
            }
        });

        item = new Gtk.ImageMenuItem.with_label (_("Trash"));
        icon = new Gtk.Image.from_icon_name ("user-trash", Gtk.IconSize.MENU);
        item.set_always_show_image (true);
        item.set_image (icon);
        menu.append (item);
        item.activate.connect (() => {
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
            	string path;
    			string label;
                string book_path;
            	path = line.split (" ")[0];
                var file = File.new_for_uri (path);
                label = line.slice (line.index_of (" ") + 1, line.length);
                book_path = file.get_parse_name ();
                Icon _icon = get_user_icon (book_path);
				item = new Gtk.ImageMenuItem.with_label (label);
				item.set_always_show_image (true);
				icon = new Gtk.Image.from_icon_name (_icon.to_string (), Gtk.IconSize.MENU);
				item.set_image (icon);
				menu.append(item);
                item.activate.connect (() => {
                    try{
                        GLib.AppInfo.launch_default_for_uri (path, null);
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

    public static GLib.Icon? get_user_icon (string path) {
        if (path[0:3] == "smb" || path[0:3] == "ssh" || path[0:3] == "ftp" || path[0:3] == "net" || path[0:3] == "dav") {
            return new GLib.ThemedIcon ("folder-remote");
        } else if (path == GLib.Environment.get_home_dir ()) {
            return new GLib.ThemedIcon ("user-home");
        } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.DESKTOP)) {
            return new GLib.ThemedIcon ("user-desktop");
        } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.DOCUMENTS)) {
            return new GLib.ThemedIcon ("folder-documents");
        } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.DOWNLOAD)) {
            return new GLib.ThemedIcon ("folder-download");
        } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.MUSIC)) {
            return new GLib.ThemedIcon ("folder-music");
        } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.PICTURES)) {
            return new GLib.ThemedIcon ("folder-pictures");
        } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.PUBLIC_SHARE)) {
            return new GLib.ThemedIcon ("folder-publicshare");
        } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.TEMPLATES)) {
            return new GLib.ThemedIcon ("folder-templates");
        } else if (path == GLib.Environment.get_user_special_dir (GLib.UserDirectory.VIDEOS)) {
            return new GLib.ThemedIcon ("folder-videos");
        } else if ((FileUtils.test (path, FileTest.IS_DIR)) == false) {
            return new GLib.ThemedIcon ("text-markdown");
        } else {
            return new GLib.ThemedIcon ("folder");
        }
    }

    public static void make_quit () {
        item = new Gtk.ImageMenuItem.with_label(_("Quit"));
        icon = new Gtk.Image.from_icon_name ("application-exit", Gtk.IconSize.MENU);
        item.set_always_show_image(true);
        item.set_image(icon);
        item.activate.connect(() => {
            Gtk.main_quit();
        });
        menu.append (item);
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
                    print ("Bookmarks changed, updating menu...\n");
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