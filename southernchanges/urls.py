from django.conf.urls import patterns, include, url
from django.conf import settings
from django.contrib import admin
from django.contrib.sitemaps import views as sitemap_views
from django.views.generic import TemplateView

from southernchanges_app.sitemaps import IssueSitemap, ArticleSitemap

admin.autodiscover()

sitemaps = {
  'issues': IssueSitemap,
  'articles': ArticleSitemap
}


from southernchanges_app.views import index, acknowledgments, searchform, browse, issue_toc, issue_tei, article_display, topics, topic_toc, send_file

urlpatterns = patterns('southernchanges_app.views',
    url(r'^admin/', include(admin.site.urls)),
    url(r'^$', 'index', name='site-index'),
    url(r'^acknowledgments$', 'acknowledgments', name='acknowledgments'),
    url(r'^browse$', 'browse', name='browse'),
    url(r'^topics$', 'topics', name='topics'),
    url(r'^topics/(?P<topic_id>[^/]+)/$', 'topic_toc', name='topic_toc'),
    url(r'^(?P<doc_id>[^/]+)/$', 'issue_toc', name="issue_toc"),
    url(r'^(?P<doc_id>[^/]+)/tei/$', 'issue_tei', name="issue_tei"),
    url(r'^(?P<doc_id>[^/]+)/(?P<div_id>[^/]+)/$', 'article_display', name='article_display'),
    url(r'^search$', 'searchform', name='search'),
    url(r'^(?P<basename>[^/]+)/download$', 'send_file', name='send_file'),

    # robots.txt and sitemaps
    url(r'^robots\.txt$',
        TemplateView.as_view(template_name='robots.txt',
        content_type='text/plain'), name='robots.txt'),
    url(r'^sitemap\.xml$', sitemap_views.index, {'sitemaps': sitemaps},
        name='sitemap-index'),
    url(r'^sitemap-(?P<section>.+)\.xml$', sitemap_views.sitemap, {'sitemaps': sitemaps},
        name='sitemap'),

    # django admin
    url(r'^admin/', include(admin.site.urls)),
    
    )

if settings.DEBUG:
  urlpatterns += patterns(
    url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.STATIC_ROOT } ),
)
