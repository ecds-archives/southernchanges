import re
from django import template

register = template.Library()

@register.filter
def get_item(dictionary, key):
    return dictionary.get(key)

@register.filter
def strip_page(str):
    try:
        new_str = str.split('p.')[1]
    except:
        try:
            new_str = re.split('\d\d\d\d, ', str)[1]
        except:
            new_str = ''
    return new_str.strip()


@register.filter
def strip_head(str):
    new_str = re.sub('Southern\sChanges.\s+', '', str)
    return new_str.strip()


@register.filter
def strip_year(str):
    try:
        new_str = re.search(r'\d\d\d\d', str).group(0)
    except:
        new_str = ''
    return new_str


@register.filter
def x100(num):
    return float(num) * 100

@register.filter
def strip_dc(str):
    new_str = re.sub('\n', ' ', str)
    return new_str.strip()

@register.filter
def strip_id(str):
    stripped = str.split('_')[-1].lstrip(0).lstrip(0)
    return stripped
