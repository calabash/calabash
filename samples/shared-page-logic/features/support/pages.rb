# Some pages depend on each other. Set up an auto-loader.
# We could also simply require every file in features/pages.

pages_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'pages'))

autoload :SharedLoginPage, File.join(pages_dir, 'shared_login_page')
