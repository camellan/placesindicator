project('com.github.camellan.placesindicator', 'vala', 'c',version: '1.0.0')

indicators_dir = join_paths(get_option('prefix'), get_option('libdir'), 'wingpanel')
gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)


shared_module(
    meson.project_name(),
    'src/PlacesIndicator.vala',
    name_prefix: '',
    dependencies: [
        dependency('glib-2.0', version: '>=2.32'),
        dependency('gio-2.0'),
        dependency('gio-unix-2.0'),
        dependency('gmodule-2.0'),
        dependency('gtk+-3.0', version: '>=3.10'),
        dependency('gee-0.8'),
        dependency('wingpanel-2.0'),

    ],
    install: true,
    install_dir: indicators_dir
)

subdir('po')
