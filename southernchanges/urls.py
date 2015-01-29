from django.conf.urls import patterns, include, url
#from django.conf.urls import patterns, include, url
#from django.conf.urls.defaults import *
from django.conf import settings
#from django.conf.urls.static import static
#from django.contrib.staticfiles.urls import staticfiles_urlpatterns
#from django.conf.urls import patterns
#from django.core.urlresolvers import reverse
#from django.contrib.sitemaps import Sitemap, FlatPageSitemap, GenericSitemap
# from blog.models import Entry

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()
'''
class ViewSitemap(Sitemap):
    """Reverse static views for XML sitemap."""
    def items(self):
        # Return list of url names for views to include in sitemap
        return ['index', 'overview', 'acknowledgements', 'search' ]

    def location(self, item):
        return reverse(item)

sitemaps = {
    'flatpages': FlatPageSitemap,
    'views': ViewSitemap,
    #'blog': GenericSitemap(info_dict, priority=0.6),
}
'''

from southernchanges_app.views import *

urlpatterns = patterns('southernchanges_app.views',
    url(r'^$', 'index', name='index'),
    url(r'^overview$', 'overview', name='overview'),
    url(r'^acknowledgments$', 'acknowledgments', name='acknowledgments'),
    url(r'^search$', 'searchform', name='search'),
    url(r'^issue$', 'issues', name='issues'),
    url(r'^topics$', 'topics', name='topics'),
    url(r'^topics/(?P<topic_id>[^/]+)/$', 'topic_toc', name='topic_toc'),
    url(r'^(?P<doc_id>[^/]+)/contents$', 'issue_toc', name="issue_toc"),
    url(r'^(?P<doc_id>[^/]+)/issue$', 'issue_display', name="issue_display"),
    url(r'^(?P<doc_id>[^/]+)/(?P<div_id>[^/]+)/$', 'article_display', name='article_display'),
    url(r'^(?P<doc_id>[^/]+)/xml/$', 'issue_xml', name='issue_xml'),
    url(r'^(?P<basename>[^/]+)/download$', 'send_file', name='send_file')
    # the sitemap
    # (r'^sitemap\.xml$', 'django.contrib.sitemaps.views.sitemap', {'sitemaps': sitemaps})
    )

if settings.DEBUG:
  urlpatterns += patterns(
    url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.STATIC_ROOT } ),
)
