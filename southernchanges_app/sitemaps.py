from django.contrib.sitemaps import Sitemap
from django.core.urlresolvers import reverse

from southernchanges_app.models import Issue, Article


class IssueSitemap(Sitemap):
    # change frequency & priority unknown
    
    def items(self):
        return Issue.objects.only('id', 'last_modified')

    def location(self, item):
        return reverse('issue_toc', kwargs={'doc_id': item.id})

    def lastmod(self, item):
        return item.last_modified


class ArticleSitemap(Sitemap):
    # change frequency & priority unknown
    
    def items(self):
        return Article.objects.only('issue_id', 'id', 'last_modified')

    def location(self, item):
        return reverse('article_display', kwargs={'doc_id': item.issue_id, 'div_id': item.id})

    def lastmod(self, item):
        return item.last_modified

