import os
import re
import logging
import mimetypes
from urllib import urlencode

from django.core.servers.basehttp import FileWrapper
from django.core.paginator import Paginator, InvalidPage, EmptyPage
from django.conf import settings
from django.shortcuts import render
from django.http import HttpResponse, Http404
from django.template import RequestContext
from django.contrib import messages

from southernchanges_app.models import Issue, Article, ArticlePid, Topic, TopicArticle
from southernchanges_app.forms import SearchForm
from eulexistdb.exceptions import DoesNotExist 
from eulexistdb.db import ExistDBException

logger = logging.getLogger(__name__)


def index(request):
  return render(request, 'index.html')

def acknowledgments(request):
  return render(request, 'acknowledgments.html')

def searchform(request):
    query_error = False
    "Search by keyword/author/title/article_date"
    form = SearchForm(request.GET)
    response_code = None
    context = {'searchform': form}
    search_opts = {}
    url_params = {}
    number_of_results = 20
      
    if form.is_valid():
        if 'keyword' in form.cleaned_data and form.cleaned_data['keyword']:
            search_opts['fulltext_terms'] = '%s' % form.cleaned_data['keyword']
            url_params['keyword'] = '%s' % form.cleaned_data['keyword']
        if 'author' in form.cleaned_data and form.cleaned_data['author']:
            search_opts['author__contains'] = '%s' % form.cleaned_data['author']
            url_params['author'] = '%s' % form.cleaned_data['author']
        if 'title' in form.cleaned_data and form.cleaned_data['title']:
            search_opts['head__fulltext_terms'] = '%s' % form.cleaned_data['title']
            url_params['title'] = '%s' % form.cleaned_data['title']
        if 'article_date' in form.cleaned_data and form.cleaned_data['article_date']:
            search_opts['date__contains'] = '%s' % form.cleaned_data['article_date'] 
            url_params['date'] = '%s' % form.cleaned_data['article_date']
        
        try:               
            articles = Article.objects.only("id", "head", "author", "date", "issue_id", "pages").also('fulltext_score') \
                                      .filter(**search_opts).order_by('-fulltext_score')                                  
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
            range_dict = {}

            for page in searchform_page.paginator.page_range:
                range_dict[page] = str(searchform_paginator.page(page).start_index()) + ' - ' +  \
                                   str(searchform_paginator.page(page).end_index())

            param_list = []                      
            for k in url_params.iterkeys():
                param_list.append(k + '=' + url_params[k])
            url_params = '&'.join(param_list)
                               
        
            context['articles'] = searchform_page.object_list
            context['items'] = searchform_page
            context['range_lookup'] = range_dict
            context['keyword'] = form.cleaned_data['keyword']
            context['author'] = form.cleaned_data['author']
            context['title'] = form.cleaned_data['title']
            context['article_date'] = form.cleaned_data['article_date']
            context['url_params'] = url_params        

            response = render(request, 'search_results.html', context)                 
        except ExistDBException as e:
            query_error = True
            if 'Cannot parse' in e.message():
                messages.error(request, 'Your search query could not be parsed.  ' + 'Please revise your search and try again.')
            else:
                # generic error message for any other exception
                messages.error(request, 'There was an error processing your search.')
            response = render(request, 'search.html',{'searchform': form, 'request': request})
        
    else:
        response = render(request, 'search.html', {"searchform": form})

    if response_code is not None:
        response.status_code = response_code
    if query_error:
        response.status_code = 400

    return response
  

def browse(request):
    "Browse list of issues"
    context = {}
    issues_1 = ['1978-1979']
    issues_2 = ['1980-1984']
    issues_3 = ['1985-1989']
    issues_4 = ['1990-1994']
    issues_5 = ['1995-1999']
    issues_6 = ['2000-2003']
    issues = Issue.objects.only('id', 'date', 'head', 'year').order_by('date')
    
    for issue in issues:
        year = int(issue.year)
        if year < 1980:
            issues_1.append(issue)
        elif year > 1979 and year < 1985:
            issues_2.append(issue)
        elif year > 1984 and year < 1990:
            issues_3.append(issue)
        elif year > 1989 and year < 1995:
            issues_4.append(issue)
        elif year > 1994 and year < 2000:
            issues_5.append(issue)
        elif year > 1999:
            issues_6.append(issue)          
    groups = [issues_1, issues_2, issues_3, issues_4, issues_5, issues_6]
  
    context['issues'] = issues
    context['groups'] = groups
  
    return render(request, 'browse.html', context)



def issue_toc(request, doc_id):
    "Display the contents of a single issue."
  
    # Get position of current issue
    ids = Issue.objects.only('id').order_by('id')
    list = []
    for i in ids:
        list.append(i.id)
    position = list.index(doc_id)

    # Create id dict for next, current, and previous issues
    id_dict = {}
    id_dict['current'] = doc_id
    if position != 0:
        id_dict['previous'] = list[position-1]
    else:
        id_dict['previous'] = None
    try:
        id_dict['next'] = list[position+1]
    except:
        id_dict['next'] = None

    # Get next, current, and previous issues
    queryset = Issue.objects.filter(id__in=[x for x in id_dict.values() if x is not None]).order_by('id')
    # Filters on queryset would be more efficient. Not sure why it doesn't work.
    if position != 0 and position != 109:
        previous_issue = queryset[0]
        issue = queryset[1]
        next_issue = queryset[2]
    elif position == 0:
        previous_issue = None
        issue = queryset[0]
        next_issue = queryset[1]
    elif position == 109:
        previous_issue = queryset[0]
        issue = queryset[1]
        next_issue = None
    
    return render(request, 'issue_toc.html', {'issue': issue, 'previous_issue': previous_issue, 'next_issue': next_issue})


def issue_tei(request, doc_id):
    "Display xml of a single issue."
    try:
        doc = Issue.objects.get(id__exact=doc_id)
    except:
        raise Http404
    tei_xml = doc.serializeDocument(pretty=True)
    return HttpResponse(tei_xml, content_type='application/xml')
    
def article_display(request, doc_id, div_id):
    "Display the contents of a single article."
    if 'keyword' in request.GET:
        search_terms = request.GET['keyword']
        url_params = '?' + urlencode({'keyword': search_terms})
        filter = {'highlight': search_terms}    
    else:
        search_terms = None
        url_params = ''
        filter = {}
    try:
        return_fields = ['issue__title', 'issue__publisher', 'issue__issued_date', 'issue__created_date', 'issue__rights', 'issue__series', 'issue__source', 'pid', 'issue_id', 'issue_title', 'next_id', 'next_title', 'previous_id', 'previous_title']
        article = Article.objects.also(*return_fields).filter(issue__id=doc_id).filter(**filter).get(id=div_id)
        pid = ArticlePid.objects.get(id=div_id)
        body = article.xsl_transform(filename=os.path.join(settings.BASE_DIR, 'southernchanges_app', 'xslt', 'article.xsl'))
        return render(request, 'article_display.html', {'article': article, 'pid': pid, 'body' : body.serialize(), 'search_terms': search_terms})
    except DoesNotExist:
        raise Http404

    
def topics(request):
    "See a list of topics."
    topics = Topic.objects.all()
    rows = [topics[x:x+3] for x in xrange(0, len(topics), 3)]
    return render(request, 'topics.html', {'topics' : topics, 'rows':rows})


def topic_toc(request, topic_id):
    "Browse articles in a single topic."
    topic = Topic.objects.get(id__exact=topic_id)
    return_fields = ['issue_id', 'article_id', 'article_author', 'article_title', 'article_type', 'date']
    results = TopicArticle.objects.also(*return_fields).filter(topic_id=('#' + topic_id)).order_by('-degree')
    
    return render(request, 'topic_toc.html', {'topic' : topic, 'results' : results})



def send_file(request, basename):
    if basename[2] == '_':
        extension = '.zip'
    else:
        extension = '.txt'
    filepath = 'static/txt/' + re.sub(r'_1204', '', basename ) + extension
    filename  = os.path.join(settings.BASE_DIR, filepath )
    download_name = basename + extension
    wrapper      = FileWrapper(open(filename))
    content_type = mimetypes.guess_type(filename)[0]
    response     = HttpResponse(wrapper,content_type=content_type)
    response['Content-Length']      = os.path.getsize(filename)    
    response['Content-Disposition'] = "attachment; filename=%s"%download_name
    return response


