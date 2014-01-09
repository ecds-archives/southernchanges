import os
import re
from urllib import urlencode
import logging

from django.conf import settings
from django.shortcuts import render, render_to_response
from django.http import HttpResponse, Http404
from django.core.paginator import Paginator, InvalidPage, EmptyPage, PageNotAnInteger
from django.template import RequestContext
from django.shortcuts import redirect

from southernchanges_app.models import Issue, Article, Fields, TeiDoc, Topics
from southernchanges_app.forms import SearchForm

from eulxml.xmlmap.core import load_xmlobject_from_file
from eulxml.xmlmap.teimap import Tei, TeiDiv, _TeiBase, TEI_NAMESPACE, xmlmap
from eulcommon.djangoextras.http.decorators import content_negotiation
from eulexistdb.query import escape_string
from eulexistdb.exceptions import DoesNotExist # ReturnedMultiple needed also ?

logger = logging.getLogger(__name__)

def index(request):
  return render_to_response('index.html', context_instance=RequestContext(request))

def overview(request):
  return render_to_response('overview.html', context_instance=RequestContext(request))

def acknowledgments(request):
  return render_to_response('acknowledgments.html', context_instance=RequestContext(request))

def searchform(request):
    "Search by keyword/author/title/article_date"
    form = SearchForm(request.GET)
    response_code = None
    context = {'searchform': form}
    search_opts = {}
    number_of_results = 20
      
    if form.is_valid():

        if 'keyword' in form.cleaned_data and form.cleaned_data['keyword']:
            search_opts['fulltext_terms'] = '%s' % form.cleaned_data['keyword']
        if 'author' in form.cleaned_data and form.cleaned_data['author']:
            search_opts['author__contains'] = '%s' % form.cleaned_data['author']
        if 'title' in form.cleaned_data and form.cleaned_data['title']:
            search_opts['head__fulltext_terms'] = '%s' % form.cleaned_data['title']
        if 'article_date' in form.cleaned_data and form.cleaned_data['article_date']:
            search_opts['date__contains'] = '%s' % form.cleaned_data['article_date']
              
        articles = Article.objects.only("id", "head", "author", "date", "issue_id", "pages").filter(**search_opts).order_by('-fulltext_score')

        searchform_paginator = Paginator(articles, number_of_results)
        
        try:
            page = int(request.GET.get('page', '1'))
        except ValueError:
            page = 1
        # If page request (9999) is out of range, deliver last page of results.
        try:
            searchform_page = searchform_paginator.page(page)
        except (EmptyPage, InvalidPage):
            searchform_page = searchform_paginator.page(paginator.num_pages)

        context['articles'] = articles
        context['articles_paginated'] = searchform_page
        context['keyword'] = form.cleaned_data['keyword']
        context['author'] = form.cleaned_data['author']
        context['title'] = form.cleaned_data['title']
        context['article_date'] = form.cleaned_data['article_date']
        
        response = render_to_response('search_results.html', context, context_instance=RequestContext(request))
                 
        
    else:
        response = render(request, 'search.html', {"searchform": form})
       
    if response_code is not None:
        response.status_code = response_code
    return response
  

def issues(request):
  "Browse list of issues"
  context = {}
  issues_1 = ['1978-1982']
  issues_2 = ['1983-1987']
  issues_3 = ['1988-1992']
  issues_4 = ['1993-1999']
  issues_5 = ['2000-2003']
  issues = Issue.objects.only('id', 'date', 'head', 'year').order_by('date')
  for issue in issues:
    if int(issue.year) < 1983:
      issues_1.append(issue)
    if int(issue.year) > 1982 and int(issue.year) < 1988:
      issues_2.append(issue)
    if int(issue.year) > 1987 and int(issue.year) < 1993:
      issues_3.append(issue)
    if int(issue.year) > 1992 and int(issue.year) < 2000:
      issues_4.append(issue)
    if int(issue.year) > 1999:
      issues_5.append(issue)
  groups = [issues_1, issues_2, issues_3, issues_4, issues_5]

  "Browse list of topics"
  topics = Topics.objects.all()
  
  context['issues'] = issues
  context['groups'] = groups
  context['topics'] = topics
  
  return render_to_response('issues.html', context, context_instance=RequestContext(request))

def topics(request):
  "See a list of topics."
  topics = Topics.objects.all()
  return render_to_response('topics.html', {'topics' : topics}, context_instance=RequestContext(request))

def topic_toc(request, topic_id):
  "Browse articles in a single topic."
  topic = Topics.objects.get(id__exact=topic_id)
  extra_fields = ['issue__id']
  articles = Article.objects.also(*extra_fields).filter(ana__contains=topic_id)
  return render_to_response('topic_toc.html', {'topic' : topic, 'articles' : articles}, context_instance=RequestContext(request))

def issue_toc(request, doc_id):
  "Display the contents of a single issue."
  ids = Issue.objects.only('id').order_by('id')
  list = []
  for i in ids:
    list.append(i.id)
  position = list.index(doc_id)
  try:
    prev = list[position-1]
  except:
    prev = None
  try:
    next = list[position+1]
  except:
    next = None
  id_list = [prev, doc_id, next]
      
  issues= Issue.objects.filter(id__in=id_list)
  issue_list =[]
  for i in issues:
    issue_list.append(i)
  for i in issue_list:
    issue = issue_list[1]
    prev_issue = issue_list[0]
    next_issue = issue_list[2]

  return render_to_response('issue_toc.html', {'issue': issue, 'id_list': id_list, 'issue_list': issue_list, 'prev_issue': prev_issue, 'next_issue': next_issue}, context_instance=RequestContext(request))

def issue_display(request, doc_id):
    "Display the contents of a single issue."
    try:
        issue = Issue.objects.get(id__exact=doc_id)
        format = issue.xsl_transform(filename=os.path.join(settings.BASE_DIR, '..', 'southernchanges_app', 'xslt', 'issue.xslt'))
        return render_to_response('issue_display.html', {'issue': issue, 'format': format.serialize()}, context_instance=RequestContext(request))
    except DoesNotExist:
        raise Http404

def article_display(request, doc_id, div_id):
  "Display the contents of a single article."
  if 'keyword' in request.GET:
    search_terms = request.GET['keyword']
    url_params = '?' + urlencode({'keyword': search_terms})
    filter = {'highlight': search_terms}    
  else:
    url_params = ''
    filter = {}
  try:
    return_fields = ['issue_id', 'issue_title', 'nextdiv_id', 'nextdiv_title', 'prevdiv_id', 'prevdiv_title', 'nextdiv_pages', 'prevdiv_pages', 'nextdiv_type', 'prevdiv_type']
    article = Article.objects.also(*return_fields).filter(issue__id=doc_id).filter(**filter).get(id=div_id)
    body = article.xsl_transform(filename=os.path.join(settings.BASE_DIR, '..', 'southernchanges_app', 'xslt', 'issue.xslt'))
    return render_to_response('article_display.html', {'article': article, 'body' : body.serialize()}, context_instance=RequestContext(request))
  except DoesNotExist:
        raise Http404


