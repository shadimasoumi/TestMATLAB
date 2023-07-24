"""To publish HTML docs at GitHub Pages, create .nojekyll file."""

from __future__ import annotations

import os
import urllib.parse
from typing import Any

import sphinx
from sphinx.application import Sphinx
from sphinx.environment import BuildEnvironment


def _get_domain_from_url(url: str) -> str:
    """Get the domain from a URL."""
    return url and urllib.parse.urlparse(url).hostname or ''


def create_nojekyll_and_cname(app: Sphinx, env: BuildEnvironment) -> None:
    """Manage the ``.nojekyll`` and ``CNAME`` files for GitHub Pages.

    For HTML-format builders (e.g. 'html', 'dirhtml') we unconditionally create
    the ``.nojekyll`` file to signal that GitHub Pages should not run Jekyll
    processing.

    If the :confval:`html_baseurl` option is set, we also create a CNAME file
    with the domain from ``html_baseurl``, so long as it is not a ``github.io``
    domain.

    If this extension is loaded and the domain in ``html_baseurl`` no longer
    requires a CNAME file, we remove any existing ``CNAME`` files from the
    output directory.
    """
    if app.builder.format != 'html':
        return

    open(os.path.join(app.builder.outdir, '.nojekyll'), 'wb').close()
    cname_path = os.path.join(app.builder.outdir, 'CNAME')

    domain = _get_domain_from_url(app.config.html_baseurl)
    # Filter out GitHub Pages domains, as they do not require CNAME files.
    if domain and not domain.endswith(".github.io"):
        with open(cname_path, 'w', encoding="utf-8") as f:
            # NOTE: don't write a trailing newline. The `CNAME` file that's
            # auto-generated by the GitHub UI doesn't have one.
            f.write(domain)
    else:
        try:
            os.unlink(cname_path)
        except FileNotFoundError:
            pass


def setup(app: Sphinx) -> dict[str, Any]:
    app.connect('env-updated', create_nojekyll_and_cname)
    return {'version': sphinx.__display_version__, 'parallel_read_safe': True}
