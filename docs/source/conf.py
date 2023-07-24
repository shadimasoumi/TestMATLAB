# Configuration file for the Sphinx documentation builder.

# -- Project information

project = 'PSProcessing'
copyright = '2023, Shadi'
author = 'Shadi'
import os
import sys
release = '0.1'
version = '0.1.0'


# -- General configuration

matlab_src_dir = os.path.dirname(os.path.abspath(__file__))
matlab_show_property_default_value = True
matlab_short_links = True

extensions = [
    'sphinx.ext.viewcode',   
    'sphinx.ext.duration',
    'sphinx.ext.doctest',
    'sphinxcontrib.matlab',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.intersphinx',
   
]

primary_domain = "mat"

intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}
intersphinx_disabled_domains = ['std']

templates_path = ['_templates']

# -- Options for HTML output

html_theme = 'sphinx_rtd_theme'

# -- Options for EPUB output
epub_show_urls = 'footnote'

