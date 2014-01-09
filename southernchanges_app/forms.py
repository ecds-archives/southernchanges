from django import forms

#  views.searchbox is using the following code
#  if 'author' in form.cleaned_data and form.cleaned_data['author']:
#  search_opts['Letter.letter_author__fulltext_terms'] = '%s' % form.cleaned_data['author']

class SearchForm(forms.Form):
    "Search letters by title/author/keyword"
    keyword = forms.CharField(required=False)
    title = forms.CharField(required=False)
    author = forms.CharField(required=False)
    article_date = forms.CharField(required=False)
    
    def clean(self):
        """Custom form validation."""
        cleaned_data = self.cleaned_data

        keyword = cleaned_data.get('keyword')
        title = cleaned_data.get('title')
        author = cleaned_data.get('author')
        article_date = cleaned_data.get('article_date')

        "Validate at least one term has been entered"
        if not keyword and not author and not title and not article_date:
            del cleaned_data['keyword']
            del cleaned_data['title']
            del cleaned_data['article_date']
            del cleaned_data['author']

            raise forms.ValidationError("Please enter search terms.")

        return cleaned_data
