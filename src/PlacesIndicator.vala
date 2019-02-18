// valac -X -D'GETTEXT_PACKAGE="com.github.camellan.placesindicator"' -D NEWMETHOD --pkg gtk+-3.0 --pkg appindicator3-0.1 --pkg glib-2.0 PlacesIndicator.vala


using Gtk;
using AppIndicator;

public class IndicatorPlaces {
	public static int main(string[] args) {
		Gtk.init(ref args);

		var indicator = new Indicator("places", "system-file-manager",
				                      IndicatorCategory.APPLICATION_STATUS);
		if (!(indicator is Indicator)) return -1;

		indicator.set_status(IndicatorStatus.ACTIVE);

        string user_home = GLib.Environment.get_home_dir ();

		var menu = new Gtk.Menu();

		var sep = new Gtk.SeparatorMenuItem();

		var home = new Gtk.MenuItem.with_label(_("Home Folder"));

        home.activate.connect(() => {
        	try{
        		GLib.AppInfo.launch_default_for_uri ("file:" + user_home, null);
        	}
            catch (GLib.Error error) {
                warning ("Error opening home directory: %s", error.message);
            }
        });

        menu.attach(home, 0, 1, 0, 1);

        var root = new Gtk.MenuItem.with_label(_("Root"));
        root.activate.connect(() => {
        	try{
        		GLib.AppInfo.launch_default_for_uri ("file:///", null);
        	}
            catch (GLib.Error error) {
                warning ("Error opening root directory: %s", error.message);
            }
        });

        menu.attach(root, 0, 1, 0, 1);

        var recent = new Gtk.MenuItem.with_label(_("Recent"));
        recent.activate.connect(() => {
        	try{
        		GLib.AppInfo.launch_default_for_uri ("recent:///", null);
        	}
            catch (GLib.Error error) {
                warning ("Error opening recent directory: %s", error.message);
            }
        });

        menu.attach(recent, 0, 1, 0, 1);

        var net = new Gtk.MenuItem.with_label(_("Network"));
        net.activate.connect(() => {
        	try{
        		GLib.AppInfo.launch_default_for_uri ("network:///", null);
        	}
            catch (GLib.Error error) {
                warning ("Error opening network directory: %s", error.message);
            }
        });

        menu.attach(net, 0, 1, 0, 1);

        var trash = new Gtk.MenuItem.with_label(_("Trash"));
        trash.activate.connect(() => {
        	try{
        		GLib.AppInfo.launch_default_for_uri ("trash:///", null);
        	}
            catch (GLib.Error error) {
                warning ("Error opening trash: %s", error.message);
            }
        });

        menu.attach(trash, 0, 1, 0, 1);
        menu.attach(sep, 0, 1, 0, 1);

        string config_dir;
        config_dir = GLib.Path.build_filename (user_home, ".config");

        string filename = GLib.Path.build_filename (config_dir,
                                                    "gtk-3.0",
                                                    "bookmarks",
                                                    null);

        var file = GLib.File.new_for_path (filename);

        if (!file.query_exists ()) {
            stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
            return 1;
        }

        try {
            var dis = new DataInputStream (file.read ());
            string line;
            while ((line = dis.read_line (null)) != null) {
                var path = line.split(" ")[0];
                var label = line.split(" ")[1];
                var item = new Gtk.MenuItem.with_label(label);
                item.activate.connect(() => {
                    try{
                        GLib.AppInfo.launch_default_for_uri (path, null);
                    }
                    catch (GLib.Error error) {
                        warning ("Error opening directory: %s", error.message);
                    }
                });
                menu.attach(item, 0, 1, 0, 1);

            }
        }
        catch (GLib.Error error) {
            warning ("%s", error.message);
        }

        var sepp = new Gtk.SeparatorMenuItem();
        menu.attach(sepp, 0, 1, 0, 1);

        var quit = new Gtk.MenuItem.with_label(_("Quit"));
        quit.activate.connect(() => {
        	Gtk.main_quit();
        });
        menu.attach(quit, 0, 1, 0, 1);

        menu.show_all();

		indicator.set_menu(menu);

		Gtk.main();
		return 0;
	}
}