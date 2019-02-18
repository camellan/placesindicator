# project name and programming language
project('com.github.camellan.placesindicator', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

asresources = gnome.compile_resources(
  'as-resources', 'data/' + meson.project_name() + '.gresource.xml',
  source_dir: 'data',
  c_name: 'as'
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'src/PlacesIndicator.vala',
    asresources,
    vala_args: [
        '--pkg=posix'
    ],
    dependencies: [
        dependency('glib-2.0'),
        dependency('gtk+-3.0'),
        dependency('appindicator3-0.1')
    ],
    install: true
)

#Install our .desktop file so the Applications Menu will see it
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.desktop.in'),
    output: meson.project_name() + '.desktop',
    type: 'desktop',
    install: true,
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    install_dir: join_paths(get_option('datadir'), 'applications')
)

#Install our .appdata.xml file so AppCenter will see it
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.appdata.xml.in'),
    output: meson.project_name() + '.appdata.xml',
    install: true,
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

#Install icons
icon_sizes = ['128', '64', '48', '32', '24', '16']

foreach i : icon_sizes
    install_data(
        join_paths('data/icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data(
        join_paths('data/icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

subdir('po')
