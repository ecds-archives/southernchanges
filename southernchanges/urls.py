#from django.conf.urls import patterns, include, url
from django.conf.urls.defaults import *
from django.conf import settings
from django.conf.urls.static import static
from django.contrib.staticfiles.urls import staticfiles_urlpatterns


# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

from southernchanges_app.views import index, overview, acknowledgments, searchform, issues, issue_toc, issue_display, article_display, topics, topic_toc, issue_xml

urlpatterns = patterns('southernchanges_app.views',
    url(r'^$', 'index', name='index'),
    url(r'^overview$', 'overview', name='overview'),
    url(r'^acknowledgments$', 'acknowledgments', name='acknowledgments'),
    url(r'^search$', 'searchform', name='search'),
    url(r'^issue$', 'issues', name='issues'),
    url(r'^topics$', 'topics', name='topics'),
    url(r'^(?P<doc_id>[^/]+)/contents$', 'issue_toc', name="issue_toc"),
    url(r'^(?P<doc_id>[^/]+)/issue$', 'issue_display', name="issue_display"),
    url(r'^(?P<doc_id>[^/]+)/(?P<div_id>[^/]+)$', 'article_display', name='article_display'),
    url(r'^(?P<doc_id>[^/]+)/xml/$', 'issue_xml', name='issue_xml'),
    url(r'^(?P<topic_id>[^/]+)/articles$', 'topic_toc', name='topic_toc'),
    )

if settings.DEBUG:
  urlpatterns += patterns(
    url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.STATIC_ROOT } ),
)



