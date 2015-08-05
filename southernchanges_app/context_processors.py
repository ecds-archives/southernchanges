from southernchanges_app.forms import SearchForm


def issue_search(request):
    '''Template context processor: add issue search form
    (:class:`~southernchanges_app.forms.SearchForm`) to context so it can be
    used on any page.'''
    return  {
        'search_form': SearchForm()
    }
