# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
import datetime
# sys.path.insert(0, os.path.abspath('.'))


# Configuration file for the Sphinx documentation builder.

# -- Project information

project = 'nmgc'
copyright = '{0}, {1}'.format(datetime.datetime.now().year, 'Sacha Gavino')
authors = 'Christophe Cossou, Sacha Gavino, Wasim Iqbal, Maxime Ruaud, Valentine Wakelam'

# The full version, including alpha/beta/rc tags
release = '2.0'

# -- General configuration

extensions = [
    # 'sphinx.ext.duration',
    # 'sphinx.ext.doctest',
    # 'sphinx.ext.autodoc',
    # 'sphinx.ext.autosummary',
    # 'sphinx.ext.intersphinx',
]

intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}
intersphinx_disabled_domains = ['std']

templates_path = ['_templates']

# -- Options for LaTeX output 

latex_elements = {
    'sphinxsetup': 'VerbatimColor={rgb}{0.95,0.95,0.95}',
}

primary_color = '#000000'


# -- Options for HTML output

html_theme = 'cloud_sptheme' #'sphinx_rtd_theme'
#html_theme_path = ["_themes", ]

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# -- Options for EPUB output
epub_show_urls = 'footnote'